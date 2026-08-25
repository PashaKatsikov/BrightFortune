import '../models/enemy_def.dart';

class LocationDef {
  final int index;
  final String id;
  final String name;
  final String description;
  final String background;
  final int levelCount;
  final List<EnemyCategory> unlockedCategories;

  const LocationDef({
    required this.index,
    required this.id,
    required this.name,
    required this.description,
    required this.background,
    required this.unlockedCategories,
    this.levelCount = 15,
  });
}
