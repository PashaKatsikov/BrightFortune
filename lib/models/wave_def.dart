enum Lane { north, east, south, west }

class SpawnEvent {
  final String enemyId;
  final Lane lane;
  final double timeOffset; // seconds after wave start
  final double hpMultiplier;
  final double speedMultiplier;

  const SpawnEvent({
    required this.enemyId,
    required this.lane,
    required this.timeOffset,
    this.hpMultiplier = 1,
    this.speedMultiplier = 1,
  });
}

class WaveDef {
  final int number; // 1..7
  final List<SpawnEvent> spawns;
  final bool isDangerous;
  final double warningLeadTime;

  const WaveDef({
    required this.number,
    required this.spawns,
    this.isDangerous = false,
    this.warningLeadTime = 4,
  });

  double get duration {
    if (spawns.isEmpty) return 0;
    return spawns.map((e) => e.timeOffset).reduce((a, b) => a > b ? a : b) + 6;
  }
}
