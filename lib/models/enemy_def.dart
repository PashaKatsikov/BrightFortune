enum EnemyCategory { common, special, elite, boss }

/// Static template describing one kind of enemy. Actual in-battle enemies
/// are spawned with stats scaled from this template by the wave generator.
class EnemyDef {
  final String id;
  final String name;
  final String sprite;
  final EnemyCategory category;
  final double baseHp;
  final double baseSpeed; // world units / second
  final double wallDamage; // damage dealt per attack tick to a wall
  final double coreDamage; // damage dealt per attack tick to the Star Core
  final double attackInterval; // seconds between attacks once in range
  final int coinReward;
  final int shardReward;
  final double radius; // render / collision radius in world units
  final bool ranged; // stands off at `range` instead of hugging the target
  final double range;
  final double damageReduction; // flat damage reduction vs tower hits (armor)
  final double slowResistance; // 0 = no resistance, 1 = immune to slow
  final double wallDamageMultiplier;

  const EnemyDef({
    required this.id,
    required this.name,
    required this.sprite,
    required this.category,
    required this.baseHp,
    required this.baseSpeed,
    required this.wallDamage,
    required this.coreDamage,
    required this.attackInterval,
    required this.coinReward,
    this.shardReward = 0,
    this.radius = 34,
    this.ranged = false,
    this.range = 0,
    this.damageReduction = 0,
    this.slowResistance = 0,
    this.wallDamageMultiplier = 1,
  });
}
