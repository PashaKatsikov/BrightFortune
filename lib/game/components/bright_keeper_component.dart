import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../../core/assets.dart';
import '../arena_layout.dart';
import '../bright_fortune_game.dart';
import '../sprite_loader.dart';

/// A friendly visitor that drifts across the garden during a quiet
/// intermission between waves. Tapping it grants a small, situational gift
/// (see [BrightFortuneGame.onBrightKeeperTapped]); left alone, it simply
/// wanders off screen after a few seconds.
class BrightKeeperComponent extends PositionComponent with TapCallbacks {
  final BrightFortuneGame game;
  static const double _lifespan = 5.5;
  double _life = _lifespan;
  bool _claimed = false;

  BrightKeeperComponent({required this.game}) : super(anchor: Anchor.center, size: Vector2.all(96), priority: 9);

  @override
  Future<void> onLoad() async {
    final fromLeft = game.rng.nextBool();
    final y = 150 + game.rng.nextDouble() * (ArenaLayout.height - 300);
    position = Vector2(fromLeft ? -70 : ArenaLayout.width + 70, y);
    final target = Vector2(fromLeft ? ArenaLayout.width + 70 : -70, y);

    final sprite = await SpriteLoader.load(Assets.brightKeeper);
    final aspect = sprite.srcSize.y / sprite.srcSize.x;
    final spriteComp = SpriteComponent(
      sprite: sprite,
      size: Vector2(96, 96 * aspect),
      anchor: Anchor.center,
      position: size / 2,
      // The menu artwork always faces the same way; mirror it when drifting
      // right-to-left so the Keeper visibly walks in its direction of travel.
      scale: fromLeft ? Vector2.all(1) : Vector2(-1, 1),
    );
    add(spriteComp);
    add(MoveToEffect(target, EffectController(duration: _lifespan)));
    add(
      ScaleEffect.by(
        Vector2.all(1.08),
        EffectController(duration: 0.5, alternate: true, infinite: true),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_claimed) return;
    _life -= dt;
    if (_life <= 0) removeFromParent();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_claimed) return;
    _claimed = true;
    game.onBrightKeeperTapped(position);
    add(
      ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(duration: 0.25),
        onComplete: removeFromParent,
      ),
    );
  }
}
