import '../core/assets.dart';
import '../models/enemy_def.dart';

class EnemyCatalog {
  EnemyCatalog._();

  static const fastCreature = EnemyDef(
    id: 'enemy_fast',
    name: 'Swift Sprite',
    sprite: Assets.enemyFast,
    category: EnemyCategory.common,
    baseHp: 18,
    baseSpeed: 92,
    wallDamage: 4,
    coreDamage: 6,
    attackInterval: 0.8,
    coinReward: 3,
    radius: 28,
  );

  static const roundCreature = EnemyDef(
    id: 'enemy_round',
    name: 'Leafling',
    sprite: Assets.enemyRound,
    category: EnemyCategory.common,
    baseHp: 42,
    baseSpeed: 46,
    wallDamage: 6,
    coreDamage: 8,
    attackInterval: 1.0,
    coinReward: 4,
    radius: 30,
  );

  static const armoredSmall = EnemyDef(
    id: 'enemy_armored_small',
    name: 'Shellback',
    sprite: Assets.enemyArmoredSmall,
    category: EnemyCategory.common,
    baseHp: 58,
    baseSpeed: 55,
    wallDamage: 5,
    coreDamage: 7,
    attackInterval: 1.0,
    coinReward: 5,
    radius: 30,
    damageReduction: 2,
  );

  static const berryCreature = EnemyDef(
    id: 'enemy_berry',
    name: 'Berry Sprite',
    sprite: Assets.enemyBerry,
    category: EnemyCategory.common,
    baseHp: 26,
    baseSpeed: 102,
    wallDamage: 5,
    coreDamage: 7,
    attackInterval: 0.8,
    coinReward: 4,
    radius: 28,
  );

  static const flameAttacker = EnemyDef(
    id: 'enemy_flame_attacker',
    name: 'Blaze Charger',
    sprite: Assets.enemyFlameAttacker,
    category: EnemyCategory.special,
    baseHp: 75,
    baseSpeed: 124,
    wallDamage: 10,
    coreDamage: 14,
    attackInterval: 0.7,
    coinReward: 8,
    radius: 30,
  );

  static const heavyArmored = EnemyDef(
    id: 'enemy_heavy_armored',
    name: 'Bramble Behemoth',
    sprite: Assets.enemyHeavyArmored,
    category: EnemyCategory.special,
    baseHp: 230,
    baseSpeed: 36,
    wallDamage: 14,
    coreDamage: 18,
    attackInterval: 1.2,
    coinReward: 14,
    radius: 38,
    damageReduction: 6,
  );

  static const rangedAttacker = EnemyDef(
    id: 'enemy_ranged',
    name: 'Lotus Caster',
    sprite: Assets.enemyRanged,
    category: EnemyCategory.special,
    baseHp: 95,
    baseSpeed: 56,
    wallDamage: 8,
    coreDamage: 12,
    attackInterval: 1.3,
    coinReward: 10,
    radius: 32,
    ranged: true,
    range: 150,
  );

  static const wallBreaker = EnemyDef(
    id: 'enemy_wall_breaker',
    name: 'Stone Crusher',
    sprite: Assets.enemyWallBreaker,
    category: EnemyCategory.special,
    baseHp: 135,
    baseSpeed: 50,
    wallDamage: 16,
    coreDamage: 10,
    attackInterval: 1.0,
    coinReward: 12,
    radius: 32,
    wallDamageMultiplier: 2.2,
  );

  static const eliteGuardian = EnemyDef(
    id: 'elite_guardian',
    name: 'Elite Guardian',
    sprite: Assets.eliteGuardian,
    category: EnemyCategory.elite,
    baseHp: 560,
    baseSpeed: 42,
    wallDamage: 20,
    coreDamage: 25,
    attackInterval: 1.0,
    coinReward: 30,
    shardReward: 1,
    radius: 42,
    damageReduction: 10,
  );

  static const eliteCorruptedFruit = EnemyDef(
    id: 'elite_corrupted_fruit',
    name: 'Corrupted Bloom',
    sprite: Assets.eliteCorruptedFruit,
    category: EnemyCategory.elite,
    baseHp: 460,
    baseSpeed: 58,
    wallDamage: 22,
    coreDamage: 28,
    attackInterval: 1.0,
    coinReward: 32,
    shardReward: 1,
    radius: 40,
  );

  static const eliteStarEnergy = EnemyDef(
    id: 'elite_star_energy',
    name: 'Star Wraith',
    sprite: Assets.eliteStarEnergy,
    category: EnemyCategory.elite,
    baseHp: 420,
    baseSpeed: 62,
    wallDamage: 18,
    coreDamage: 22,
    attackInterval: 0.9,
    coinReward: 34,
    shardReward: 1,
    radius: 40,
    slowResistance: 0.6,
  );

  static const finalBoss = EnemyDef(
    id: 'final_boss',
    name: 'Shadow Radiance',
    sprite: Assets.finalBoss,
    category: EnemyCategory.boss,
    baseHp: 4200,
    baseSpeed: 28,
    wallDamage: 40,
    coreDamage: 50,
    attackInterval: 1.0,
    coinReward: 250,
    shardReward: 12,
    radius: 60,
    damageReduction: 14,
    slowResistance: 0.4,
  );

  static const List<EnemyDef> common = [fastCreature, roundCreature, armoredSmall, berryCreature];
  static const List<EnemyDef> special = [flameAttacker, heavyArmored, rangedAttacker, wallBreaker];
  static const List<EnemyDef> elite = [eliteGuardian, eliteCorruptedFruit, eliteStarEnergy];
  static const List<EnemyDef> boss = [finalBoss];

  static final Map<String, EnemyDef> byId = {
    for (final e in [...common, ...special, ...elite, ...boss]) e.id: e,
  };
}
