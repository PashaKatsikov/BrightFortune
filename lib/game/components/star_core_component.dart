import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../arena_layout.dart';
import '../bright_fortune_game.dart';
import '../sprite_loader.dart';

/// The Star Core: the fortress' central energy source, rendered with a
/// slow idle rotation and a soft glow that intensifies when energy is
/// abundant or fades toward red as its health drops.
class StarCoreComponent extends PositionComponent {
  final BrightFortuneGame game;
  late SpriteComponent _glow;
  late SpriteComponent _core;
  double _t = 0;

  StarCoreComponent({required this.game})
      : super(position: ArenaLayout.center, anchor: Anchor.center, priority: 7);

  @override
  Future<void> onLoad() async {
    final glowSprite = await SpriteLoader.load(Assets.starCoreActivationEffect);
    final coreSprite = await SpriteLoader.load(Assets.starCore);

    _glow = SpriteComponent(sprite: glowSprite, size: Vector2(360, 165), anchor: Anchor.center);
    _core = SpriteComponent(sprite: coreSprite, size: Vector2(150, 144), anchor: Anchor.center);
    add(_glow);
    add(_core);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    _core.angle = _t * 0.25;
    final pulse = 1.0 + 0.04 * (0.5 + 0.5 * (_t * 2).remainder(2).clamp(0.0, 2) - 0.5).abs();
    _glow.scale = Vector2.all(pulse);
    final hpPct = game.state.corePercent;
    _glow.opacity = 0.55 + 0.35 * hpPct;
  }
}
