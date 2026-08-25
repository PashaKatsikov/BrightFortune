import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/assets.dart';
import '../data/enemy_catalog.dart';
import '../data/tower_catalog.dart';
import '../models/enemy_def.dart';
import '../models/location_def.dart';
import '../models/tower_def.dart';
import '../models/upgrade_def.dart';
import '../models/wave_def.dart';
import '../services/audio_service.dart';
import '../services/player_progress.dart';
import 'arena_layout.dart';
import 'battle_state.dart';
import 'bell_blessing_defs.dart';
import 'collectible_defs.dart';
import 'components/arena_decor.dart';
import 'components/collectible_component.dart';
import 'components/effects_misc.dart';
import 'components/energy_beam_component.dart';
import 'components/enemy_component.dart';
import 'components/star_core_component.dart';
import 'components/tower_component.dart';
import 'components/wall_component.dart';
import 'wave_controller.dart';

const double kBurstBaseDamage = 160;
const double kBurstRadius = 700;

class BrightFortuneGame extends FlameGame {
  final LocationDef location;
  final int levelIndex;
  final List<WaveDef> waves;

  late final BattleState state;
  late final WaveController waveController;

  final math.Random rng = math.Random();
  final List<EnemyComponent> enemies = [];
  final Map<Lane, WallComponent> walls = {};

  String? bellMessage;
  double bellMessageRemaining = 0;
  BellBlessingKind? bellBlessingKind;
  bool bellBlessingClaimed = false;

  void Function(bool victory)? onGameEnded;

  double _collectibleTimer = 3.5;

  BrightFortuneGame({required this.location, required this.levelIndex, required this.waves})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: ArenaLayout.width,
            height: ArenaLayout.height,
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    final progress = PlayerProgress.instance;
    final coreMax = 260.0 * (1 + progress.upgradeBonus(UpgradeType.coreCapacity));
    final energyMax = 100.0 * (1 + progress.upgradeBonus(UpgradeType.coreCapacity));
    final wallMax = 150.0 * (1 + progress.upgradeBonus(UpgradeType.wallDurability));

    state = BattleState(
      coreMaxHp: coreMax,
      energyMax: energyMax,
      baseEnergyRegenPerSec: 9,
      baseBurstChargeRatePerSec: 4,
      initialWallHp: {for (final l in Lane.values) l: wallMax},
    );

    final world = this.world;
    await world.add(ArenaBackgroundComponent());
    await world.add(ArenaDecorComponent());

    for (final lane in Lane.values) {
      final wall = WallComponent(lane: lane, game: this);
      walls[lane] = wall;
      await world.add(wall);
    }

    for (final def in TowerCatalog.all) {
      await world.add(TowerComponent(def: def, game: this));
    }

    await world.add(StarCoreComponent(game: this));
    await world.add(EnergyBeamComponent(game: this));

    waveController = WaveController(game: this, waves: waves);
    waveController.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state.gameOver) return;

    _updateEnergyAndBurst(dt);
    state.tickBuffs(dt);
    _updateCollectibles(dt);
    waveController.update(dt);

    if (bellMessageRemaining > 0) {
      bellMessageRemaining -= dt;
      if (bellMessageRemaining <= 0) {
        bellMessage = null;
        bellBlessingKind = null;
        bellBlessingClaimed = false;
      }
    }

    if (state.coreHp <= 0 && !state.gameOver) {
      _onLevelDefeat();
    }
  }

  void _updateEnergyAndBurst(double dt) {
    final progress = PlayerProgress.instance;

    var regenMult = (1 + progress.upgradeBonus(UpgradeType.coreRegen)) *
        state.buffMultiplier(BuffType.energyRegen) *
        state.buffMultiplier(BuffType.coreBoost);
    if (state.focusedTower == TowerKind.generator && !state.boostSuppressed) {
      regenMult *= 2.5;
    }
    state.energy = (state.energy + state.baseEnergyRegenPerSec * regenMult * dt).clamp(0.0, state.energyMax);

    if (state.focusedTower != null) {
      state.energy = (state.energy - kFocusEnergyDrainPerSec * dt).clamp(0.0, state.energyMax);
    }

    if (state.energy <= 0.01) {
      state.boostSuppressed = true;
    } else if (state.energy >= state.energyMax * 0.22) {
      state.boostSuppressed = false;
    }

    final burstRate = state.baseBurstChargeRatePerSec *
        (1 + progress.upgradeBonus(UpgradeType.burstChargeSpeed)) *
        state.buffMultiplier(BuffType.burstChargeRate);
    state.burstCharge = (state.burstCharge + burstRate * dt).clamp(0.0, state.burstMax);
  }

  void _updateCollectibles(double dt) {
    _collectibleTimer -= dt;
    final currentCount = world.children.whereType<CollectibleComponent>().length;
    if (_collectibleTimer <= 0 && currentCount < 3) {
      _collectibleTimer = 3.5 + rng.nextDouble() * 3.0;
      _spawnCollectible();
    }
  }

  void _spawnCollectible() {
    final isBerry = rng.nextDouble() < 0.65;
    final list = isBerry ? kBerryDefs : kFruitDefs;
    final def = list[rng.nextInt(list.length)];

    Vector2 pos;
    var attempts = 0;
    do {
      pos = Vector2(60 + rng.nextDouble() * (ArenaLayout.width - 120), 60 + rng.nextDouble() * (ArenaLayout.height - 120));
      attempts++;
    } while (pos.distanceTo(ArenaLayout.center) < ArenaLayout.towerRadius + 70 && attempts < 12);

    world.add(CollectibleComponent(def: def, game: this, pos: pos));
  }

  // ---------------------------------------------------------------------
  // Callbacks used by components
  // ---------------------------------------------------------------------
  void spawnEnemy(EnemyComponent enemy) {
    enemies.add(enemy);
    world.add(enemy);
  }

  void onEnemyDefeated(EnemyComponent enemy) {
    enemies.remove(enemy);
    state.enemiesAliveInWave = math.max(0, state.enemiesAliveInWave - 1);
    PlayerProgress.instance.addCoins(enemy.def.coinReward);
    if (enemy.def.shardReward > 0) PlayerProgress.instance.addShards(enemy.def.shardReward);
    PlayerProgress.instance.markEnemyDefeated(enemy.def.id);
    state.coinsEarned += enemy.def.coinReward;
    state.shardsEarned += enemy.def.shardReward;
  }

  void damageWall(Lane lane, double amount) {
    final reduced = amount * (1 - state.wallShieldReduction);
    final current = state.wallHp[lane] ?? 0;
    state.wallHp[lane] = (current - reduced).clamp(0.0, state.wallMaxHp[lane] ?? 0);
  }

  void damageCore(double amount) {
    state.coreHp = (state.coreHp - amount).clamp(0.0, state.coreMaxHp);
  }

  void spawnDefeatEffect(Vector2 pos) => world.add(DefeatEffectComponent(pos: pos));

  void spawnAttackFlash(Vector2 from, Vector2 to) => world.add(AttackFlashComponent(from: from, to: to));

  void showFloatingLabel(Vector2 pos, String label) => world.add(FloatingLabelComponent(pos: pos, label: label));

  void onCollectibleExpired(CollectibleComponent c) {
    // No-op hook kept for symmetry / future use (e.g. combo tracking).
  }

  void showBellWarning(String text, {WaveDef? incomingWave}) {
    bellMessage = text;
    bellMessageRemaining = 4.0;
    bellBlessingClaimed = false;
    bellBlessingKind = incomingWave == null ? null : _pickBellBlessing(incomingWave);
  }

  /// Picks whichever blessing best answers the upcoming wave's composition:
  /// a Shield Chime against wall-breakers, an Energy Chime against tough
  /// elite/boss hitpoint sponges, or a Focus Chime otherwise.
  BellBlessingKind _pickBellBlessing(WaveDef wave) {
    final defs = wave.spawns.map((s) => EnemyCatalog.byId[s.enemyId]).whereType<EnemyDef>();
    if (defs.any((d) => d.wallDamageMultiplier > 1.5)) return BellBlessingKind.shield;
    if (defs.any((d) => d.category == EnemyCategory.elite || d.category == EnemyCategory.boss)) {
      return BellBlessingKind.energy;
    }
    return BellBlessingKind.focus;
  }

  /// Called when the player taps the Golden Bell warning banner. Grants the
  /// prepared blessing exactly once per warning.
  void claimBellBlessing() {
    final kind = bellBlessingKind;
    if (kind == null || bellBlessingClaimed) return;
    bellBlessingClaimed = true;
    kind.apply(this);
    showFloatingLabel(ArenaLayout.center, kind.label);
    AudioService.instance.playSfx(Assets.sfxRewardReceived);
  }

  void onWaveStarted(int waveNumber) {
    AudioService.instance.playSfx(Assets.sfxStarCoreActivation);
  }

  void onWaveCleared(int waveNumber) {
    final bonus = 15 + waveNumber * 6;
    PlayerProgress.instance.addCoins(bonus);
    state.coinsEarned += bonus;
    AudioService.instance.playSfx(Assets.sfxRewardReceived);
  }

  void onLevelVictory() {
    if (state.gameOver) return;
    state.gameOver = true;
    state.victory = true;

    final corePct = state.corePercent;
    final wallsIntact = walls.values.where((w) => !w.isBroken).length;
    var stars = 1;
    if (corePct >= 0.8 && wallsIntact >= 3) {
      stars = 3;
    } else if (corePct >= 0.4 && wallsIntact >= 2) {
      stars = 2;
    }

    final bonusCoins = 60 + levelIndex * 8 + location.index * 20;
    final bonusShards = 2 + (stars - 1) * 2 + (location.index);
    PlayerProgress.instance.addCoins(bonusCoins);
    PlayerProgress.instance.addShards(bonusShards);
    PlayerProgress.instance.reportLevelResult(location.index, levelIndex, stars);
    state.coinsEarned += bonusCoins;
    state.shardsEarned += bonusShards;

    AudioService.instance.playSfx(Assets.sfxLevelComplete);
    pauseEngine();
    onGameEnded?.call(true);
  }

  void _onLevelDefeat() {
    state.gameOver = true;
    state.victory = false;
    AudioService.instance.playSfx(Assets.sfxLevelFailed);
    pauseEngine();
    onGameEnded?.call(false);
  }

  void setFocus(TowerKind? kind) {
    state.focusedTower = state.focusedTower == kind ? null : kind;
  }

  void triggerBrightBurst() {
    if (state.burstCharge < state.burstMax) return;
    final progress = PlayerProgress.instance;
    final damage = kBurstBaseDamage * (1 + progress.upgradeBonus(UpgradeType.burstPower));
    for (final e in List<EnemyComponent>.of(enemies)) {
      if (e.isDead) continue;
      if (e.position.distanceTo(ArenaLayout.center) <= kBurstRadius) {
        e.takeDamage(damage);
      }
    }
    state.burstCharge = 0;
    world.add(BurstEffectComponent(pos: ArenaLayout.center));
    AudioService.instance.playSfx(Assets.sfxBrightBurst);
  }
}
