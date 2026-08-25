/// Central registry of every image / audio asset path used by the game.
class Assets {
  Assets._();

  static const String _sprites = 'assets/game/sprites';
  static const String _backgrounds = 'assets/game/backgrounds';
  static const String _ui = 'assets/game/ui';
  static const String _sfx = 'assets/Bright_Fortune_sounds_assets';

  // UI / loading
  static const String gameName = '$_ui/game_name.webp';
  static const String loadingHorizontal = '$_ui/loading_horizontal.webp';
  static const String loadingVertical = '$_ui/loading_vertical.webp';

  // Backgrounds
  static const String bgBrightGarden = '$_backgrounds/bg_bright_garden.webp';
  static const String bgBerryValley = '$_backgrounds/bg_berry_valley.webp';
  static const String bgGoldenOrchard = '$_backgrounds/bg_golden_orchard.webp';
  static const String bgBellwood = '$_backgrounds/bg_bellwood.webp';
  static const String bgStarRidge = '$_backgrounds/bg_star_ridge.webp';
  static const String bgGameplayTerrain = '$_backgrounds/bg_gameplay_terrain.webp';

  // Towers
  static const String towerBasic = '$_sprites/tower_basic.webp';
  static const String towerFast = '$_sprites/tower_fast.webp';
  static const String towerSlow = '$_sprites/tower_slow.webp';
  static const String towerHeavy = '$_sprites/tower_heavy.webp';
  static const String repairTower = '$_sprites/repair_tower.webp';
  static const String energyGenerator = '$_sprites/energy_generator.webp';

  // Core / fortress
  static const String starCore = '$_sprites/star_core.webp';
  static const String starCoreActivationEffect = '$_sprites/star_core_activation_effect.webp';
  static const String fortressGate = '$_sprites/fortress_gate.webp';
  static const String energyShield = '$_sprites/energy_shield.webp';
  static const String energyBeam = '$_sprites/energy_beam.webp';

  // Walls
  static const String wallStraight = '$_sprites/wall_straight.webp';
  static const String wallCorner = '$_sprites/wall_corner.webp';
  static const String wallGemFull = '$_sprites/wall_gem_full.webp';
  static const String wallBroken = '$_sprites/wall_broken.webp';

  // Bright Burst
  static const String brightBurstCrystal = '$_sprites/bright_burst_crystal.webp';
  static const String brightBurstEffect = '$_sprites/bright_burst_effect.webp';

  // Enemies - common
  static const String enemyFast = '$_sprites/enemy_fast.webp';
  static const String enemyRound = '$_sprites/enemy_round.webp';
  static const String enemyArmoredSmall = '$_sprites/enemy_armored_small.webp';
  static const String enemyBerry = '$_sprites/enemy_berry.webp';

  // Enemies - special
  static const String enemyFlameAttacker = '$_sprites/enemy_flame_attacker.webp';
  static const String enemyHeavyArmored = '$_sprites/enemy_heavy_armored.webp';
  static const String enemyRanged = '$_sprites/enemy_ranged.webp';
  static const String enemyWallBreaker = '$_sprites/enemy_wall_breaker.webp';

  // Enemies - elite / boss
  static const String eliteGuardian = '$_sprites/elite_guardian.webp';
  static const String eliteCorruptedFruit = '$_sprites/elite_corrupted_fruit.webp';
  static const String eliteStarEnergy = '$_sprites/elite_star_energy.webp';
  static const String finalBoss = '$_sprites/final_boss.webp';

  // Companion
  static const String brightKeeper = '$_sprites/bright_keeper.webp';

  // Effects
  static const String enemyDefeatEffect = '$_sprites/enemy_defeat_effect.webp';

  // Fruits (temporary bonuses)
  static const String fruitApple = '$_sprites/fruit_apple.webp';
  static const String fruitStrawberry = '$_sprites/fruit_strawberry.webp';
  static const String fruitBlueberry = '$_sprites/fruit_blueberry.webp';
  static const String fruitGoldenStar = '$_sprites/fruit_golden_star.webp';

  // Berries (small tactical bonuses)
  static const String berryStrawberry = '$_sprites/berry_strawberry.webp';
  static const String berryBlueberry = '$_sprites/berry_blueberry.webp';
  static const String berryRaspberry = '$_sprites/berry_raspberry.webp';
  static const String berryBlackberry = '$_sprites/berry_blackberry.webp';

  // Currency
  static const String goldenCoin = '$_sprites/golden_coin.webp';
  static const String starShard = '$_sprites/star_shard.webp';

  // Warning
  static const String goldenWarningBell = '$_sprites/golden_warning_bell.webp';

  // Decorative bells
  static const String decoBellGold = '$_sprites/deco_bell_gold.webp';
  static const String decoBellBlue = '$_sprites/deco_bell_blue.webp';
  static const String decoBellPink = '$_sprites/deco_bell_pink.webp';
  static const String decoBellPurple = '$_sprites/deco_bell_purple.webp';

  // Decorative plants / trees / bushes / stones / crystals / paths
  static const String plantFlowerYellow = '$_sprites/plant_flower_yellow.webp';
  static const String plantLeaf = '$_sprites/plant_leaf.webp';
  static const String plantStarFlower = '$_sprites/plant_star_flower.webp';
  static const String plantFern = '$_sprites/plant_fern.webp';

  static const String treeApple = '$_sprites/tree_apple.webp';
  static const String treeOrange = '$_sprites/tree_orange.webp';
  static const String treePear = '$_sprites/tree_pear.webp';
  static const String treeFlowering = '$_sprites/tree_flowering.webp';

  static const String bushStrawberry = '$_sprites/bush_strawberry.webp';
  static const String bushBlueberry = '$_sprites/bush_blueberry.webp';
  static const String bushRaspberry = '$_sprites/bush_raspberry.webp';
  static const String bushBlackberry = '$_sprites/bush_blackberry.webp';

  static const String stoneSmall = '$_sprites/stone_small.webp';
  static const String stoneFlat = '$_sprites/stone_flat.webp';
  static const String stoneCrystal = '$_sprites/stone_crystal.webp';
  static const String stoneGoldVeined = '$_sprites/stone_gold_veined.webp';

  static const String crystalBlue = '$_sprites/crystal_blue.webp';
  static const String crystalPurple = '$_sprites/crystal_purple.webp';
  static const String crystalGold = '$_sprites/crystal_gold.webp';
  static const String crystalWhite = '$_sprites/crystal_white.webp';

  static const String pathStraight = '$_sprites/path_straight.webp';
  static const String pathCorner = '$_sprites/path_corner.webp';
  static const String pathT = '$_sprites/path_t.webp';
  static const String pathCross = '$_sprites/path_cross.webp';

  // Sounds
  static const String sfxBellWarning = '$_sfx/Bell_Warning_asset.mp3';
  static const String sfxBrightBurst = '$_sfx/Bright_Burst_asset.mp3';
  static const String sfxButtonClick = '$_sfx/Button_Click_asset.mp3';
  static const String sfxCoinCollect = '$_sfx/Coin_Collect_asset.mp3';
  static const String sfxEnemyDefeat = '$_sfx/Enemy_Defeat_asset.mp3';
  static const String sfxEnergyBeam = '$_sfx/Energy_Beam_asset.mp3';
  static const String sfxLevelComplete = '$_sfx/Level_Complete_asset.mp3';
  static const String sfxLevelFailed = '$_sfx/Level_Failed_asset.mp3';
  static const String sfxMenuClose = '$_sfx/Menu_Close_asset.mp3';
  static const String sfxMenuOpen = '$_sfx/Menu_Open_asset.mp3';
  static const String sfxRewardReceived = '$_sfx/Reward_Received_asset.mp3';
  static const String sfxStarCoreActivation = '$_sfx/Star_Core_Activation_asset.mp3';
  static const String sfxWallRepair = '$_sfx/Wall_Repair_asset.mp3';

  static const List<String> allSprites = [
    towerBasic, towerFast, towerSlow, towerHeavy, repairTower, energyGenerator,
    starCore, starCoreActivationEffect, fortressGate, energyShield, energyBeam,
    wallStraight, wallCorner, wallGemFull, wallBroken,
    brightBurstCrystal, brightBurstEffect,
    enemyFast, enemyRound, enemyArmoredSmall, enemyBerry,
    enemyFlameAttacker, enemyHeavyArmored, enemyRanged, enemyWallBreaker,
    eliteGuardian, eliteCorruptedFruit, eliteStarEnergy, finalBoss,
    brightKeeper, enemyDefeatEffect,
    fruitApple, fruitStrawberry, fruitBlueberry, fruitGoldenStar,
    berryStrawberry, berryBlueberry, berryRaspberry, berryBlackberry,
    goldenCoin, starShard, goldenWarningBell,
    decoBellGold, decoBellBlue, decoBellPink, decoBellPurple,
    plantFlowerYellow, plantLeaf, plantStarFlower, plantFern,
    treeApple, treeOrange, treePear, treeFlowering,
    bushStrawberry, bushBlueberry, bushRaspberry, bushBlackberry,
    stoneSmall, stoneFlat, stoneCrystal, stoneGoldVeined,
    crystalBlue, crystalPurple, crystalGold, crystalWhite,
    pathStraight, pathCorner, pathT, pathCross,
  ];

  static const List<String> allBackgrounds = [
    bgBrightGarden, bgBerryValley, bgGoldenOrchard, bgBellwood, bgStarRidge, bgGameplayTerrain,
  ];
}
