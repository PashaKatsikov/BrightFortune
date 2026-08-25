import '../core/assets.dart';
import '../models/tower_def.dart';

class TowerCatalog {
  TowerCatalog._();

  static const basic = TowerDef(
    kind: TowerKind.basic,
    id: 'tower_basic',
    name: 'Radiant Tower',
    description: 'Steady, reliable damage to any enemy that draws near.',
    sprite: Assets.towerBasic,
    baseDamage: 13,
    baseRange: 260,
    baseAttackInterval: 0.6,
  );

  static const fast = TowerDef(
    kind: TowerKind.fast,
    id: 'tower_fast',
    name: 'Pulse Tower',
    description: 'Fires frequent bolts of light energy for rapid pressure.',
    sprite: Assets.towerFast,
    baseDamage: 5,
    baseRange: 230,
    baseAttackInterval: 0.22,
  );

  static const slow = TowerDef(
    kind: TowerKind.slow,
    id: 'tower_slow',
    name: 'Crystal Spire',
    description: 'Chills the battlefield, slowing every enemy nearby.',
    sprite: Assets.towerSlow,
    baseDamage: 3,
    baseRange: 210,
    baseAttackInterval: 1.0,
    slowFactor: 0.42,
  );

  static const heavy = TowerDef(
    kind: TowerKind.heavy,
    id: 'tower_heavy',
    name: 'Heavy Cannon',
    description: 'Slow but devastating - crushes armored attackers.',
    sprite: Assets.towerHeavy,
    baseDamage: 58,
    baseRange: 300,
    baseAttackInterval: 1.7,
    splashRadius: 46,
    armoredBonus: 1.6,
  );

  static const repair = TowerDef(
    kind: TowerKind.repair,
    id: 'repair_tower',
    name: 'Repair Tower',
    description: 'Mends damaged walls with restorative energy.',
    sprite: Assets.repairTower,
    baseRange: 320,
    repairRatePerSec: 5,
  );

  static const generator = TowerDef(
    kind: TowerKind.generator,
    id: 'energy_generator',
    name: 'Energy Generator',
    description: 'Boosts the Star Core\'s energy regeneration when focused.',
    sprite: Assets.energyGenerator,
  );

  static const List<TowerDef> attackers = [basic, fast, slow, heavy];
  static const List<TowerDef> all = [basic, fast, slow, heavy, repair, generator];

  static final Map<TowerKind, TowerDef> byKind = {for (final t in all) t.kind: t};
}
