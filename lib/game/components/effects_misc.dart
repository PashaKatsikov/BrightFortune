import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/animation.dart' show Curves;

import '../../core/assets.dart';
import '../sprite_loader.dart';

/// One-shot burst of light shown wherever an enemy is defeated.
class DefeatEffectComponent extends PositionComponent {
  DefeatEffectComponent({required Vector2 pos})
      : super(position: pos, anchor: Anchor.center, size: Vector2.all(90), priority: 12);

  @override
  Future<void> onLoad() async {
    final sprite = await SpriteLoader.load(Assets.enemyDefeatEffect);
    final s = SpriteComponent(
      sprite: sprite,
      size: size.clone(),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(s);
    s.add(ScaleEffect.by(Vector2.all(1.4), EffectController(duration: 0.35)));
    s.add(OpacityEffect.to(0, EffectController(duration: 0.35), onComplete: removeFromParent));
  }
}

/// A quick flash line drawn between an attacker and its target, giving
/// instant visual feedback for every tower shot.
class AttackFlashComponent extends Component {
  final Vector2 from;
  final Vector2 to;
  double _life = 0.12;
  final Color color;

  AttackFlashComponent({required this.from, required this.to, this.color = const Color(0xFFBFEBFF)})
      : super(priority: 11);

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_life / 0.12).clamp(0.0, 1);
    final paint = Paint()
      ..color = color.withValues(alpha: t.toDouble())
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(from.x, from.y), Offset(to.x, to.y), paint);
  }
}

/// Big radial Bright Burst visual + core activation glow, shown at the
/// Star Core whenever the special ability fires.
class BurstEffectComponent extends PositionComponent {
  BurstEffectComponent({required Vector2 pos})
      : super(position: pos, anchor: Anchor.center, size: Vector2(560, 260), priority: 13);

  @override
  Future<void> onLoad() async {
    final sprite = await SpriteLoader.load(Assets.brightBurstEffect);
    final s = SpriteComponent(
      sprite: sprite,
      size: size.clone(),
      anchor: Anchor.center,
      position: size / 2,
      scale: Vector2.all(0.2),
    );
    add(s);
    s.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.35, curve: Curves.easeOutBack)));
    s.add(OpacityEffect.to(0, EffectController(duration: 0.7, startDelay: 0.35), onComplete: removeFromParent));
  }
}

/// Small floating text label used for collectible pickups ("+50% Damage"
/// etc.) that rises and fades out.
class FloatingLabelComponent extends PositionComponent {
  final String label;
  final Color color;
  static const double _duration = 1.1;
  double _t = 0;
  late TextComponent _text;

  FloatingLabelComponent({required Vector2 pos, required this.label, this.color = const Color(0xFFFFF3C4)})
      : super(position: pos, anchor: Anchor.center, priority: 14);

  TextPaint _paintFor(double alpha) => TextPaint(
        style: TextStyle(
          color: color.withValues(alpha: alpha),
          fontSize: 22,
          fontWeight: FontWeight.w800,
          fontFamily: 'Nunito',
          shadows: [Shadow(color: const Color(0xCC000000).withValues(alpha: alpha), blurRadius: 4, offset: const Offset(0, 2))],
        ),
      );

  @override
  Future<void> onLoad() async {
    _text = TextComponent(text: label, anchor: Anchor.center, textRenderer: _paintFor(1));
    add(_text);
    add(MoveEffect.by(Vector2(0, -60), EffectController(duration: _duration)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    final alpha = (1 - _t / _duration).clamp(0.0, 1.0);
    _text.textRenderer = _paintFor(alpha);
    if (_t >= _duration) removeFromParent();
  }
}
