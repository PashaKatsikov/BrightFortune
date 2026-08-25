import 'package:flame/game.dart';

import '../models/wave_def.dart';

/// Fixed world-space layout for every battle arena. The camera always shows
/// this exact rectangle, giving a consistent top-down fixed-camera feel
/// regardless of the physical device's aspect ratio.
class ArenaLayout {
  ArenaLayout._();

  static const double width = 1600;
  static const double height = 900;

  static final Vector2 center = Vector2(width / 2, height / 2);

  static const double wallRadius = 165;
  static const double towerRadius = 250;
  // The south attacker tower sits right above the in-game HUD's bottom focus
  // bar. A full-radius placement there puts a large chunk of its sprite
  // behind that overlay, so the energy beam (which always targets the exact
  // tower center) ends up looking like it terminates past the visible art.
  // Pulling only the south tower a bit closer to the core keeps it fully
  // clear of the HUD while every other lane keeps the standard radius.
  static const double southTowerRadius = 215;
  static const double utilityRadius = 128;
  static const double coreRadius = 62;

  static Vector2 laneDirection(Lane lane) {
    switch (lane) {
      case Lane.north:
        return Vector2(0, -1);
      case Lane.east:
        return Vector2(1, 0);
      case Lane.south:
        return Vector2(0, 1);
      case Lane.west:
        return Vector2(-1, 0);
    }
  }

  static Vector2 wallPosition(Lane lane) => center + laneDirection(lane) * wallRadius;

  static Vector2 towerPosition(Lane lane) {
    final radius = lane == Lane.south ? southTowerRadius : towerRadius;
    return center + laneDirection(lane) * radius;
  }

  static final Vector2 repairTowerPosition =
      center + (Vector2(1, -1)..normalize()) * utilityRadius;
  static final Vector2 generatorPosition =
      center + (Vector2(-1, 1)..normalize()) * utilityRadius;

  static Vector2 spawnPosition(Lane lane, double t) {
    // t in [-1, 1] spread across the lane's edge segment.
    switch (lane) {
      case Lane.north:
        return Vector2(center.x + t * 260, -50);
      case Lane.south:
        return Vector2(center.x + t * 260, height + 50);
      case Lane.east:
        return Vector2(width + 50, center.y + t * 220);
      case Lane.west:
        return Vector2(-50, center.y + t * 220);
    }
  }
}
