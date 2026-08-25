import '../core/assets.dart';
import '../models/bounty_def.dart';
import 'enemy_catalog.dart';

/// The four Bestiary completion bounties - one per enemy category. Each
/// rewards a one-time currency payout plus a small permanent gameplay
/// bonus once every enemy in that category has been defeated at least once.
class BountyCatalog {
  BountyCatalog._();

  static const List<BountyDef> all = [
    BountyDef(
      id: 'bounty_common',
      name: 'Common Bestiary',
      description: 'Defeat every common creature at least once.',
      icon: Assets.goldenCoin,
      enemies: EnemyCatalog.common,
      coinReward: 80,
      bonusType: BountyBonusType.coinDrop,
      bonusMagnitude: 0.03,
      bonusLabel: '+3% Coin Drops',
    ),
    BountyDef(
      id: 'bounty_special',
      name: 'Special Bestiary',
      description: 'Defeat every special creature at least once.',
      icon: Assets.repairTower,
      enemies: EnemyCatalog.special,
      shardReward: 5,
      bonusType: BountyBonusType.repairSpeed,
      bonusMagnitude: 0.05,
      bonusLabel: '+5% Repair Speed',
    ),
    BountyDef(
      id: 'bounty_elite',
      name: 'Elite Bestiary',
      description: 'Defeat every elite creature at least once.',
      icon: Assets.brightBurstCrystal,
      enemies: EnemyCatalog.elite,
      shardReward: 12,
      bonusType: BountyBonusType.burstChargeSpeed,
      bonusMagnitude: 0.05,
      bonusLabel: '+5% Burst Charge',
    ),
    BountyDef(
      id: 'bounty_boss',
      name: 'Shadow Radiance',
      description: 'Defeat the final boss at least once.',
      icon: Assets.starCore,
      enemies: EnemyCatalog.boss,
      shardReward: 20,
      bonusType: BountyBonusType.startingEnergy,
      bonusMagnitude: 0.10,
      bonusLabel: '+10% Starting Energy',
    ),
  ];

  static final Map<String, BountyDef> byId = {for (final b in all) b.id: b};
}
