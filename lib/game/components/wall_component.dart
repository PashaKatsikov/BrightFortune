import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../../models/wave_def.dart';
import '../arena_layout.dart';
import '../bright_fortune_game.dart';
import '../sprite_loader.dart';

/// One of the four wall segments that ring the Star Core. Switches artwork
/// between its pristine and broken state as it takes damage, and lets
/// enemies pass through once destroyed.
class WallComponent extends PositionComponent {
  final Lane lane;
  final BrightFortuneGame game;

  late final SpriteComponent _spriteComponent;
  late final Sprite _healthySprite;
  late final Sprite _brokenSprite;
  bool _broken = false;
  double _flashTimer = 0;

  WallComponent({required this.lane, required this.game})
      : super(position: ArenaLayout.wallPosition(lane), anchor: Anchor.center, priority: 4);

  bool get isBroken => _broken;

  @override
  Future<void> onLoad() async {
    _healthySprite = await SpriteLoader.load(Assets.wallGemFull);
    _brokenSprite = await SpriteLoader.load(Assets.wallBroken);
    // The source artwork is a tall pillar - a natural vertical barrier for
    // the east/west lanes. North/south lanes need it rotated 90 degrees so
    // it forms a horizontal barrier instead.
    final needsRotation = lane == Lane.north || lane == Lane.south;
    size = Vector2(48, 138);
    _spriteComponent = SpriteComponent(
      sprite: _healthySprite,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      angle: needsRotation ? math.pi / 2 : 0,
    );
    add(_spriteComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final hp = game.state.wallHp[lane] ?? 0;
    final maxHp = game.state.wallMaxHp[lane] ?? 1;
    final shouldBeBroken = hp <= 0;
    if (shouldBeBroken != _broken) {
      _broken = shouldBeBroken;
      _spriteComponent.sprite = _broken ? _brokenSprite : _healthySprite;
    }
    if (_flashTimer > 0) {
      _flashTimer -= dt;
      final t = (_flashTimer / 0.15).clamp(0.0, 1);
      _spriteComponent.paint.colorFilter = ui.ColorFilter.mode(
        ui.Color.fromRGBO(255, 90, 90, t.toDouble()),
        ui.BlendMode.srcATop,
      );
    } else if (_spriteComponent.paint.colorFilter != null) {
      _spriteComponent.paint.colorFilter = null;
    }
    final pct = (hp / maxHp).clamp(0.0, 1);
    _spriteComponent.opacity = _broken ? 0.9 : (0.55 + pct * 0.45);
  }

  void flashHit() {
    _flashTimer = 0.15;
  }
}
