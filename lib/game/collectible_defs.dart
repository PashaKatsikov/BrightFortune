import '../core/assets.dart';
import '../models/upgrade_def.dart';
import '../services/player_progress.dart';
import 'battle_state.dart';
import 'bright_fortune_game.dart';

enum CollectibleKind { fruit, berry }

class CollectibleDef {
  final String id;
  final String sprite;
  final CollectibleKind kind;
  final String label;
  final void Function(BrightFortuneGame game) apply;

  const CollectibleDef({
    required this.id,
    required this.sprite,
    required this.kind,
    required this.label,
    required this.apply,
  });
}

double _durationMult() => 1 + PlayerProgress.instance.upgradeBonus(UpgradeType.fruitDuration);
double _berryMult() => 1 + PlayerProgress.instance.upgradeBonus(UpgradeType.berryEfficiency);

final List<CollectibleDef> kFruitDefs = [
  CollectibleDef(
    id: 'fruit_apple',
    sprite: Assets.fruitApple,
    kind: CollectibleKind.fruit,
    label: '+50% Tower Damage',
    apply: (g) => g.state.addBuff(BuffType.towerDamage, 0.5, 10 * _durationMult()),
  ),
  CollectibleDef(
    id: 'fruit_strawberry',
    sprite: Assets.fruitStrawberry,
    kind: CollectibleKind.fruit,
    label: '+100% Energy Regen',
    apply: (g) => g.state.addBuff(BuffType.energyRegen, 1.0, 10 * _durationMult()),
  ),
  CollectibleDef(
    id: 'fruit_blueberry',
    sprite: Assets.fruitBlueberry,
    kind: CollectibleKind.fruit,
    label: 'Enemies Slowed',
    apply: (g) => g.state.addBuff(BuffType.enemySlow, 0.3, 8 * _durationMult()),
  ),
  CollectibleDef(
    id: 'fruit_golden_star',
    sprite: Assets.fruitGoldenStar,
    kind: CollectibleKind.fruit,
    label: 'Core Empowered!',
    apply: (g) {
      g.state.addBuff(BuffType.coreBoost, 1.0, 12 * _durationMult());
      g.state.energy = g.state.energyMax;
    },
  ),
];

final List<CollectibleDef> kBerryDefs = [
  CollectibleDef(
    id: 'berry_strawberry',
    sprite: Assets.berryStrawberry,
    kind: CollectibleKind.berry,
    label: '+25% Energy Regen',
    apply: (g) => g.state.addBuff(BuffType.energyRegen, 0.25 * _berryMult(), 8),
  ),
  CollectibleDef(
    id: 'berry_blueberry',
    sprite: Assets.berryBlueberry,
    kind: CollectibleKind.berry,
    label: '+20% Attack Speed',
    apply: (g) => g.state.addBuff(BuffType.attackSpeed, 0.2 * _berryMult(), 8),
  ),
  CollectibleDef(
    id: 'berry_raspberry',
    sprite: Assets.berryRaspberry,
    kind: CollectibleKind.berry,
    label: '+40% Repair Speed',
    apply: (g) => g.state.addBuff(BuffType.repairSpeed, 0.4 * _berryMult(), 8),
  ),
  CollectibleDef(
    id: 'berry_blackberry',
    sprite: Assets.berryBlackberry,
    kind: CollectibleKind.berry,
    label: '+20% Burst Charge',
    apply: (g) => g.state.addBuff(BuffType.burstChargeRate, 0.2 * _berryMult(), 8),
  ),
];
