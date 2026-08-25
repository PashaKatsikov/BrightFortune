import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../../models/enemy_def.dart';
import '../../models/wave_def.dart';
import '../../services/audio_service.dart';
import '../arena_layout.dart';
import '../bright_fortune_game.dart';
import '../sprite_loader.dart';

/// A single enemy instance walking one of the four lanes toward the Star
/// Core, attacking whichever wall segment blocks its lane and, once that
/// wall is destroyed, the Core itself.
class EnemyComponent extends PositionComponent {
  final EnemyDef def;
  final Lane lane;
  final double hpMultiplier;
  final double speedMultiplier;
  final BrightFortuneGame game;

  late double hp;
  late double maxHp;
  bool isDead = false;
  double _attackTimer = 0;
  double _currentSlowFactor = 0;
  double _slowResetTimer = 0;
  late SpriteComponent _sprite;
  late RectangleComponent _hpBg;
  late RectangleComponent _hpFg;

  EnemyComponent({
    required this.def,
    required this.lane,
    required this.game,
    this.hpMultiplier = 1,
    this.speedMultiplier = 1,
  }) : super(anchor: Anchor.center, priority: 10) {
    position = ArenaLayout.spawnPosition(lane, (game.rng.nextDouble() * 2) - 1);
  }

  @override
  Future<void> onLoad() async {
    maxHp = def.baseHp * hpMultiplier;
    hp = maxHp;

    final sprite = await SpriteLoader.load(def.sprite);
    final diameter = def.radius * 2;
    final aspect = sprite.srcSize.y / sprite.srcSize.x;
    _sprite = SpriteComponent(
      sprite: sprite,
      size: Vector2(diameter, diameter * aspect),
      anchor: Anchor.center,
    );
    add(_sprite);

    _hpBg = RectangleComponent(
      size: Vector2(diameter, 6),
      position: Vector2(-def.radius, -diameter * aspect / 2 - 12),
      paint: Paint()..color = const Color(0x99000000),
    );
    _hpFg = RectangleComponent(
      size: Vector2(diameter, 6),
      position: Vector2(-def.radius, -diameter * aspect / 2 - 12),
      paint: Paint()..color = const Color(0xFFE84C4C),
    );
    add(_hpBg);
    add(_hpFg);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || game.state.paused) return;

    if (_slowResetTimer > 0) {
      _slowResetTimer -= dt;
      if (_slowResetTimer <= 0) _currentSlowFactor = 0;
    }

    final wall = game.walls[lane]!;
    final wallHp = game.state.wallHp[lane] ?? 0;
    final targetingWall = wallHp > 0;
    final targetPos = targetingWall ? ArenaLayout.wallPosition(lane) : ArenaLayout.center;
    final targetRadius = targetingWall ? 34.0 : ArenaLayout.coreRadius;

    final toTarget = targetPos - position;
    final distance = toTarget.length;
    final attackRange = def.ranged ? def.range : def.radius + targetRadius + 6;

    if (distance <= attackRange) {
      _attackTimer -= dt;
      if (_attackTimer <= 0) {
        _attackTimer = def.attackInterval;
        if (targetingWall) {
          game.damageWall(lane, def.wallDamage * def.wallDamageMultiplier);
          wall.flashHit();
        } else {
          game.damageCore(def.coreDamage);
        }
      }
    } else {
      final dir = toTarget..normalize();
      final speed = def.baseSpeed * speedMultiplier * (1 - _currentSlowFactor);
      position += dir * speed * dt;
    }

    _hpFg.size = Vector2((hp / maxHp).clamp(0.0, 1) * _hpBg.size.x, 6);
  }

  void applySlowAura(double factor) {
    if (factor > _currentSlowFactor) {
      _currentSlowFactor = factor * (1 - def.slowResistance);
    }
    _slowResetTimer = 0.25;
  }

  void takeDamage(double amount) {
    if (isDead) return;
    hp -= amount;
    if (hp <= 0) {
      _die();
    }
  }

  void _die() {
    isDead = true;
    game.onEnemyDefeated(this);
    AudioService.instance.playSfx(Assets.sfxEnemyDefeat);
    game.spawnDefeatEffect(position);
    removeFromParent();
  }

  void forceRemoveAlive() {
    // Used when the battle ends abruptly (defeat) to clean up without
    // granting rewards or defeat-effects.
    isDead = true;
    removeFromParent();
  }
}
