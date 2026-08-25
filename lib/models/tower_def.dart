enum TowerKind { basic, fast, slow, heavy, repair, generator }

/// Static definition of one of the six fixed defensive structures placed
/// around the Star Core. Every level uses the same six structures; only
/// enemy waves and upgrade levels change the difficulty.
class TowerDef {
  final TowerKind kind;
  final String id;
  final String name;
  final String description;
  final String sprite;
  final double baseDamage;
  final double baseRange;
  final double baseAttackInterval;
  final double splashRadius;
  final double armoredBonus; // extra damage multiplier vs armored enemies
  final double slowFactor; // fraction speed reduction applied while in range
  final double repairRatePerSec;

  const TowerDef({
    required this.kind,
    required this.id,
    required this.name,
    required this.description,
    required this.sprite,
    this.baseDamage = 0,
    this.baseRange = 0,
    this.baseAttackInterval = 1,
    this.splashRadius = 0,
    this.armoredBonus = 1,
    this.slowFactor = 0,
    this.repairRatePerSec = 0,
  });

  bool get isAttacker => kind == TowerKind.basic || kind == TowerKind.fast || kind == TowerKind.slow || kind == TowerKind.heavy;
}
