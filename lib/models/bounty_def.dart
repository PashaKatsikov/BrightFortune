import 'enemy_def.dart';

/// Which running gameplay multiplier a completed bounty permanently boosts.
enum BountyBonusType { coinDrop, repairSpeed, burstChargeSpeed, startingEnergy }

/// A one-time reward for fully discovering a whole Bestiary category (i.e.
/// defeating every enemy in [enemies] at least once). Claiming it pays out a
/// currency bonus and unlocks a small permanent gameplay bonus that stacks
/// across every future battle.
class BountyDef {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<EnemyDef> enemies;
  final int coinReward;
  final int shardReward;
  final BountyBonusType bonusType;
  final double bonusMagnitude;
  final String bonusLabel;

  const BountyDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.enemies,
    this.coinReward = 0,
    this.shardReward = 0,
    required this.bonusType,
    required this.bonusMagnitude,
    required this.bonusLabel,
  });
}
