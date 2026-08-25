enum UpgradeCurrency { coins, shards }

enum UpgradeType {
  coreCapacity,
  coreRegen,
  towerDamage,
  towerAttackSpeed,
  wallDurability,
  repairEfficiency,
  burstPower,
  burstChargeSpeed,
  fruitDuration,
  berryEfficiency,
}

class UpgradeDef {
  final UpgradeType type;
  final String name;
  final String description;
  final String icon;
  final UpgradeCurrency currency;
  final int maxLevel;
  final int baseCost;
  final double costGrowth;
  final double perLevelBonus; // meaning depends on stat; see PlayerStats
  final String unit;

  const UpgradeDef({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.currency,
    required this.perLevelBonus,
    this.unit = '%',
    this.maxLevel = 10,
    this.baseCost = 120,
    this.costGrowth = 1.35,
  });

  int costForLevel(int currentLevel) {
    // currentLevel is 0-based count of levels already purchased.
    return (baseCost * _pow(costGrowth, currentLevel)).round();
  }

  static double _pow(double base, int exp) {
    double v = 1;
    for (var i = 0; i < exp; i++) {
      v *= base;
    }
    return v;
  }
}
