import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/tower_def.dart';
import '../../models/wave_def.dart';
import '../arena_layout.dart';
import '../bright_fortune_game.dart';

/// Persistent glowing energy beam drawn from the Star Core to whichever
/// structure currently has the player's energy focus. Hidden when nothing
/// is focused.
class EnergyBeamComponent extends Component {
  final BrightFortuneGame game;
  double _t = 0;

  EnergyBeamComponent({required this.game}) : super(priority: 5);

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  static Lane _laneFor(TowerKind kind) {
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

  Vector2 _targetPosition(TowerKind kind) {
    switch (kind) {
      case TowerKind.repair:
        return ArenaLayout.repairTowerPosition;
      case TowerKind.generator:
        return ArenaLayout.generatorPosition;
      default:
        return ArenaLayout.towerPosition(_laneFor(kind));
    }
  }

  @override
  void render(Canvas canvas) {
    final focused = game.state.focusedTower;
    if (focused == null) return;
    final target = _targetPosition(focused);

    // Always a straight line from the Star Core's exact center to the
    // focused structure's exact center - no curvature/offset, so the beam
    // never appears to stop short of, or veer past, the target's center.
    final start = ArenaLayout.center;
    final suppressed = game.state.boostSuppressed;
    final baseColor = suppressed ? const Color(0xFF8A7A9A) : const Color(0xFFFFEFAF);

    // Subtle pulsing via width/alpha only (no positional wobble) so the
    // beam keeps some energy to it without ever bending off the straight
    // path between the two centers.
    final pulse = 0.5 + 0.5 * math.sin(_t * 10);

    final glowPaint = Paint()
      ..color = baseColor.withValues(alpha: suppressed ? 0.25 : 0.30 + 0.1 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(start.toOffset(), target.toOffset(), glowPaint);

    final corePaint = Paint()
      ..color = baseColor.withValues(alpha: suppressed ? 0.5 : 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + pulse * 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start.toOffset(), target.toOffset(), corePaint);
  }
}
