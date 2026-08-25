import 'package:flame/components.dart';

import '../../models/tower_def.dart';
import '../../models/upgrade_def.dart';
import '../../models/wave_def.dart';
import '../../services/player_progress.dart';
import '../arena_layout.dart';
import '../battle_state.dart';
import '../bright_fortune_game.dart';
import '../sprite_loader.dart';
import 'enemy_component.dart';
import 'wall_component.dart';

const double kFocusEnergyDrainPerSec = 15;
const double kFocusDamageMultiplier = 2.2;
const double kFocusRateMultiplier = 1.6;

/// A fixed defensive structure: one of the four attacking towers, the
/// Repair Tower, or the Energy Generator. All six share the same focus /
/// energy mechanics but differ in what they actually do each frame.
class TowerComponent extends PositionComponent {
  final TowerDef def;
  final BrightFortuneGame game;

  double _attackCooldown = 0;
  double _pulse = 0;
  late SpriteComponent _sprite;

  TowerComponent({required this.def, required this.game})
      : super(
          position: def.kind == TowerKind.repair
              ? ArenaLayout.repairTowerPosition
              : def.kind == TowerKind.generator
                  ? ArenaLayout.generatorPosition
                  : ArenaLayout.towerPosition(_laneForAttacker(def.kind)),
          anchor: Anchor.center,
          priority: 6,
        );

  static Lane _laneForAttacker(TowerKind kind) {
    switch (kind) {
      case TowerKind.basic:
        return Lane.north;
      case TowerKind.heavy:
        return Lane.east;
      case TowerKind.slow:
        return Lane.south;
      case TowerKind.fast:
        return Lane.west;
      default:
        return Lane.north;
    }
  }

  bool get isFocused => game.state.focusedTower == def.kind;
  bool get boostActive => isFocused && !game.state.boostSuppressed;

  @override
  Future<void> onLoad() async {
    final sprite = await SpriteLoader.load(def.sprite);
    final aspect = sprite.srcSize.y / sprite.srcSize.x;
    final w = def.kind == TowerKind.repair || def.kind == TowerKind.generator ? 118.0 : 108.0;
    size = Vector2(w, w * aspect);
    // A child's local origin is this component's top-left corner, so a
    // centered sprite must sit at size/2 to actually line up with the
    // tower's own position - anything else silently draws the artwork half
    // a sprite up and to the left of where the tower really is.
    _sprite = SpriteComponent(
      sprite: sprite,
      size: size.clone(),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt;
    if (boostActive) {
      final s = 1.0 + 0.06 * (0.5 + 0.5 * (_pulse * 6).remainder(2) - 0.5).abs();
      _sprite.scale = Vector2.all(s.clamp(1.0, 1.08));
    } else {
      _sprite.scale = Vector2.all(1.0);
    }

    switch (def.kind) {
      case TowerKind.repair:
        _updateRepair(dt);
        break;
      case TowerKind.generator:
        // Generator's effect (core regen boost) is applied centrally by the
        // game loop based on `isFocused`; nothing to do here per-frame.
        break;
      default:
        _updateAttacker(dt);
    }
  }

  void _updateAttacker(double dt) {
    final progress = PlayerProgress.instance;
    final dmgBonus = 1 + progress.upgradeBonus(UpgradeType.towerDamage) + game.state.buffMultiplier(BuffType.towerDamage) - 1;
    final rateBonus = 1 + progress.upgradeBonus(UpgradeType.towerAttackSpeed) + game.state.buffMultiplier(BuffType.attackSpeed) - 1;

    final focusDmg = boostActive ? kFocusDamageMultiplier : 1.0;
    final focusRate = boostActive ? kFocusRateMultiplier : 1.0;

    final damage = def.baseDamage * dmgBonus * focusDmg;
    final interval = def.baseAttackInterval / (rateBonus * focusRate);

    if (def.kind == TowerKind.slow) {
      final slowFactor = boostActive ? def.slowFactor * 1.5 : def.slowFactor;
      final range = boostActive ? def.baseRange * 1.2 : def.baseRange;
      for (final e in game.enemies) {
        if (e.isDead) continue;
        if (e.position.distanceTo(position) <= range) {
          e.applySlowAura(slowFactor);
        }
      }
    }

    _attackCooldown -= dt;
    if (_attackCooldown > 0) return;

    EnemyComponent? target;
    double bestDist = double.infinity;
    for (final e in game.enemies) {
      if (e.isDead) continue;
      final d = e.position.distanceTo(position);
      if (d <= def.baseRange && d < bestDist) {
        bestDist = d;
        target = e;
      }
    }

    if (target == null) return;
    _attackCooldown = interval;

    var finalDamage = damage;
    if (target.def.damageReduction > 0 && def.armoredBonus > 1) {
      finalDamage *= def.armoredBonus;
    }
    finalDamage = (finalDamage - target.def.damageReduction).clamp(1, double.infinity);

    target.takeDamage(finalDamage);
    game.spawnAttackFlash(position, target.position);

    if (def.splashRadius > 0) {
      for (final e in game.enemies) {
        if (e == target || e.isDead) continue;
        if (e.position.distanceTo(target.position) <= def.splashRadius) {
          e.takeDamage(finalDamage * 0.5);
        }
      }
    }
  }

  void _updateRepair(double dt) {
    final progress = PlayerProgress.instance;
    final effBonus = 1 + progress.upgradeBonus(UpgradeType.repairEfficiency) + game.state.buffMultiplier(BuffType.repairSpeed) - 1;
    final focusMult = boostActive ? 4.0 : 1.0;
    final rate = def.repairRatePerSec * effBonus * focusMult;

    WallComponent? target;
    double worstPct = 1.0;
    for (final wall in game.walls.values) {
      final hp = game.state.wallHp[wall.lane] ?? 0;
      final maxHp = game.state.wallMaxHp[wall.lane] ?? 1;
      if (hp >= maxHp) continue;
      final d = ArenaLayout.wallPosition(wall.lane).distanceTo(position);
      if (d > def.baseRange) continue;
      final pct = hp / maxHp;
      if (pct < worstPct) {
        worstPct = pct;
        target = wall;
      }
    }

    if (target != null) {
      final lane = target.lane;
      final maxHp = game.state.wallMaxHp[lane]!;
      final newHp = ((game.state.wallHp[lane] ?? 0) + rate * dt).clamp(0.0, maxHp);
      game.state.wallHp[lane] = newHp;
    }
  }
}