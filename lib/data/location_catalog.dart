import '../core/assets.dart';
import '../models/enemy_def.dart';
import '../models/location_def.dart';

class LocationCatalog {
  LocationCatalog._();

  static const List<LocationDef> all = [
    LocationDef(
      index: 0,
      id: 'bright_garden',
      name: 'Bright Garden',
      description: 'A sunlit magical garden where the journey begins.',
      background: Assets.bgBrightGarden,
      unlockedCategories: [EnemyCategory.common],
    ),
    LocationDef(
      index: 1,
      id: 'berry_valley',
      name: 'Berry Valley',
      description: 'A lush valley thick with berry vines and denser waves.',
      background: Assets.bgBerryValley,
      unlockedCategories: [EnemyCategory.common, EnemyCategory.special],
    ),
    LocationDef(
      index: 2,
      id: 'golden_orchard',
      name: 'Golden Orchard',
      description: 'A grand golden orchard where elite guardians awaken.',
      background: Assets.bgGoldenOrchard,
      unlockedCategories: [EnemyCategory.common, EnemyCategory.special, EnemyCategory.elite],
    ),
    LocationDef(
      index: 3,
      id: 'bellwood',
      name: 'Bellwood',
      description: 'A magical forest of warning bells and frequent elites.',
      background: Assets.bgBellwood,
      unlockedCategories: [EnemyCategory.common, EnemyCategory.special, EnemyCategory.elite],
    ),
    LocationDef(
      index: 4,
      id: 'star_ridge',
      name: 'Star Ridge',
      description: 'The final ridge of pure Star Energy - the ultimate test.',
      background: Assets.bgStarRidge,
      unlockedCategories: [EnemyCategory.common, EnemyCategory.special, EnemyCategory.elite, EnemyCategory.boss],
    ),
  ];

  static LocationDef byIndex(int index) => all[index];
}
