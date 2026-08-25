import '../core/assets.dart';
import '../models/upgrade_def.dart';

class UpgradeCatalog {
  UpgradeCatalog._();

  static const List<UpgradeDef> all = [
    UpgradeDef(
      type: UpgradeType.coreCapacity,
      name: 'Core Capacity',
      description: 'Increases the Star Core\'s maximum energy reserve.',
      icon: Assets.starCore,
      currency: UpgradeCurrency.shards,
      perLevelBonus: 12,
      unit: '%',
      baseCost: 6,
      costGrowth: 1.4,
    ),
    UpgradeDef(
      type: UpgradeType.coreRegen,
      name: 'Core Regeneration',
      description: 'Increases how quickly the Star Core replenishes energy.',
      icon: Assets.starCoreActivationEffect,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 10,
      baseCost: 150,
    ),
    UpgradeDef(
      type: UpgradeType.towerDamage,
      name: 'Tower Damage',
      description: 'Increases the damage dealt by every defensive tower.',
      icon: Assets.towerBasic,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 10,
      baseCost: 180,
    ),
    UpgradeDef(
      type: UpgradeType.towerAttackSpeed,
      name: 'Tower Attack Speed',
      description: 'Towers fire faster, dealing more damage per second.',
      icon: Assets.towerFast,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 8,
      baseCost: 180,
    ),
    UpgradeDef(
      type: UpgradeType.wallDurability,
      name: 'Wall Durability',
      description: 'Increases the maximum strength of all defensive walls.',
      icon: Assets.wallGemFull,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 12,
      baseCost: 140,
    ),
    UpgradeDef(
      type: UpgradeType.repairEfficiency,
      name: 'Repair Efficiency',
      description: 'The Repair Tower restores walls more quickly.',
      icon: Assets.repairTower,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 12,
      baseCost: 140,
    ),
    UpgradeDef(
      type: UpgradeType.burstPower,
      name: 'Bright Burst Power',
      description: 'Increases the damage of the Bright Burst ability.',
      icon: Assets.brightBurstCrystal,
      currency: UpgradeCurrency.shards,
      perLevelBonus: 14,
      baseCost: 8,
      costGrowth: 1.4,
    ),
    UpgradeDef(
      type: UpgradeType.burstChargeSpeed,
      name: 'Bright Burst Charge Speed',
      description: 'The Bright Burst ability charges up faster.',
      icon: Assets.brightBurstEffect,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 10,
      baseCost: 170,
    ),
    UpgradeDef(
      type: UpgradeType.fruitDuration,
      name: 'Fruit Bonus Duration',
      description: 'Magical fruit bonuses last longer once collected.',
      icon: Assets.fruitGoldenStar,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 10,
      baseCost: 130,
    ),
    UpgradeDef(
      type: UpgradeType.berryEfficiency,
      name: 'Berry Efficiency',
      description: 'Berry resources grant stronger tactical bonuses.',
      icon: Assets.berryRaspberry,
      currency: UpgradeCurrency.coins,
      perLevelBonus: 10,
      baseCost: 130,
    ),
  ];

  static final Map<UpgradeType, UpgradeDef> byType = {for (final u in all) u.type: u};
}
