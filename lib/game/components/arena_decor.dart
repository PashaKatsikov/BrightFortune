import 'package:flame/components.dart';

import '../../core/assets.dart';
import '../arena_layout.dart';
import '../sprite_loader.dart';

/// Static terrain background filling the whole arena.
class ArenaBackgroundComponent extends SpriteComponent {
  ArenaBackgroundComponent()
      : super(size: Vector2(ArenaLayout.width, ArenaLayout.height), priority: 0);

  @override
  Future<void> onLoad() async {
    sprite = await SpriteLoader.load(Assets.bgGameplayTerrain);
  }
}

/// A handful of purely decorative props scattered around the arena corners
/// so the battlefield doesn't feel empty, matching the garden theme.
class ArenaDecorComponent extends Component {
  static const List<String> _props = [
    Assets.treeApple,
    Assets.treeOrange,
    Assets.bushStrawberry,
    Assets.bushBlueberry,
    Assets.stoneFlat,
    Assets.stoneCrystal,
    Assets.plantFern,
    Assets.plantStarFlower,
  ];

  static final List<Vector2> _positions = [
    Vector2(90, 90),
    Vector2(ArenaLayout.width - 90, 90),
    Vector2(90, ArenaLayout.height - 90),
    Vector2(ArenaLayout.width - 90, ArenaLayout.height - 90),
    Vector2(ArenaLayout.width * 0.5, 60),
    Vector2(ArenaLayout.width * 0.5, ArenaLayout.height - 60),
    Vector2(60, ArenaLayout.height * 0.5),
    Vector2(ArenaLayout.width - 60, ArenaLayout.height * 0.5),
  ];

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < _props.length; i++) {
      final sprite = await SpriteLoader.load(_props[i]);
      add(SpriteComponent(
        sprite: sprite,
        position: _positions[i],
        size: Vector2(76, 76),
        anchor: Anchor.center,
        priority: 1,
      ));
    }
  }
}
