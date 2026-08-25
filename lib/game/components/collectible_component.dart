import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../../core/assets.dart';
import '../../services/audio_service.dart';
import '../bright_fortune_game.dart';
import '../collectible_defs.dart';
import '../sprite_loader.dart';

/// A tappable fruit or berry that grants a temporary buff when collected.
/// Automatically fades out and removes itself if left uncollected.
class CollectibleComponent extends PositionComponent with TapCallbacks {
  final CollectibleDef def;
  final BrightFortuneGame game;
  double _life = 9;
  bool _collected = false;
  late SpriteComponent _spriteComp;

  CollectibleComponent({required this.def, required this.game, required Vector2 pos})
      : super(position: pos, anchor: Anchor.center, size: Vector2.all(64), priority: 8);

  @override
  Future<void> onLoad() async {
    final sprite = await SpriteLoader.load(def.sprite);
    _spriteComp = SpriteComponent(
      sprite: sprite,
      size: size.clone(),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_spriteComp);
    add(
      ScaleEffect.by(
        Vector2.all(1.12),
        EffectController(duration: 0.55, alternate: true, infinite: true),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_collected) return;
    _life -= dt;
    if (_life <= 1.5) {
      _spriteComp.opacity = (_life / 1.5).clamp(0.0, 1);
    }
    if (_life <= 0) {
      removeFromParent();
      game.onCollectibleExpired(this);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_collected) return;
    _collected = true;
    def.apply(game);
    AudioService.instance.playSfx(Assets.sfxCoinCollect);
    game.showFloatingLabel(position, def.label);
    game.onCollectibleExpired(this);
    add(
      ScaleEffect.to(
        Vector2.all(1.6),
        EffectController(duration: 0.25),
        onComplete: removeFromParent,
      ),
    );
    _spriteComp.add(OpacityEffect.to(0, EffectController(duration: 0.25)));
  }
}
