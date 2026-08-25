/// Central registry of every image / audio asset path used by the game.
class Assets {
  Assets._();

  static const String _sprites = 'assets/game/sprites';
  static const String _backgrounds = 'assets/game/backgrounds';
  static const String _ui = 'assets/game/ui';
  static const String _sfx = 'assets/Bright_Fortune_sounds_assets';

  // UI / loading
  static const String gameName = '$_ui/game_name.png';
  static const String loadingHorizontal = '$_ui/loading_horizontal.png';
  static const String loadingVertical = '$_ui/loading_vertical.png';

  // Backgrounds
  static const String bgBrightGarden = '$_backgrounds/bg_bright_garden.png';
  static const String bgBerryValley = '$_backgrounds/bg_berry_valley.png';
  static const String bgGoldenOrchard = '$_backgrounds/bg_golden_orchard.png';
  static const String bgBellwood = '$_backgrounds/bg_bellwood.png';
  static const String bgStarRidge = '$_backgrounds/bg_star_ridge.png';
  static const String bgGameplayTerrain = '$_backgrounds/bg_gameplay_terrain.png';

  // Towers
  static const String towerBasic = '$_sprites/tower_basic.png';
  static const String towerFast = '$_sprites/tower_fast.png';
  static const String towerSlow = '$_sprites/tower_slow.png';
  static const String towerHeavy = '$_sprites/tower_heavy.png';
  static const String repairTower = '$_sprites/repair_tower.png';
  static const String energyGenerator = '$_sprites/energy_generator.png';

  // Core / fortress
  static const String starCore = '$_sprites/star_core.png';
  static const String starCoreActivationEffect = '$_sprites/star_core_activation_effect.png';
  static const String fortressGate = '$_sprites/fortress_gate.png';
  static const String energyShield = '$_sprites/energy_shield.png';
  static const String energyBeam = '$_sprites/energy_beam.png';

  // Walls
  static const String wallStraight = '$_sprites/wall_straight.png';
  static const String wallCorner = '$_sprites/wall_corner.png';
  static const String wallGemFull = '$_sprites/wall_gem_full.png';
  static const String wallBroken = '$_sprites/wall_broken.png';

  // Bright Burst
  static const String brightBurstCrystal = '$_sprites/bright_burst_crystal.png';
  static const String brightBurstEffect = '$_sprites/bright_burst_effect.png';

  // Enemies - common
  static const String enemyFast = '$_sprites/enemy_fast.png';
  static const String enemyRound = '$_sprites/enemy_round.png';
  static const String enemyArmoredSmall = '$_sprites/enemy_armored_small.png';
  static const String enemyBerry = '$_sprites/enemy_berry.png';

  // Enemies - special
  static const String enemyFlameAttacker = '$_sprites/enemy_flame_attacker.png';
  static const String enemyHeavyArmored = '$_sprites/enemy_heavy_armored.png';
  static const String enemyRanged = '$_sprites/enemy_ranged.png';
  static const String enemyWallBreaker = '$_sprites/enemy_wall_breaker.png';

  // Enemies - elite / boss
  static const String eliteGuardian = '$_sprites/elite_guardian.png';
  static const String eliteCorruptedFruit = '$_sprites/elite_corrupted_fruit.png';
  static const String eliteStarEnergy = '$_sprites/elite_star_energy.png';
  static const String finalBoss = '$_sprites/final_boss.png';

  // Companion
  static const String brightKeeper = '$_sprites/bright_keeper.png';

  // Effects
  static const String enemyDefeatEffect = '$_sprites/enemy_defeat_effect.png';

  // Fruits (temporary bonuses)
  static const String fruitApple = '$_sprites/fruit_apple.png';
  static const String fruitStrawberry = '$_sprites/fruit_strawberry.png';
  static const String fruitBlueberry = '$_sprites/fruit_blueberry.png';
  static const String fruitGoldenStar = '$_sprites/fruit_golden_star.png';

  // Berries (small tactical bonuses)
  static const String berryStrawberry = '$_sprites/berry_strawberry.png';
  static const String berryBlueberry = '$_sprites/berry_blueberry.png';
  static const String berryRaspberry = '$_sprites/berry_raspberry.png';
  static const String berryBlackberry = '$_sprites/berry_blackberry.png';

  // Currency
  static const String goldenCoin = '$_sprites/golden_coin.png';
  static const String starShard = '$_sprites/star_shard.png';

  // Warning
  static const String goldenWarningBell = '$_sprites/golden_warning_bell.png';

  // Decorative bells
  static const String decoBellGold = '$_sprites/deco_bell_gold.png';
  static const String decoBellBlue = '$_sprites/deco_bell_blue.png';
  static const String decoBellPink = '$_sprites/deco_bell_pink.png';
  static const String decoBellPurple = '$_sprites/deco_bell_purple.png';

  // Decorative plants / trees / bushes / stones / crystals / paths
  static const String plantFlowerYellow = '$_sprites/plant_flower_yellow.png';
  static const String plantLeaf = '$_sprites/plant_leaf.png';
  static const String plantStarFlower = '$_sprites/plant_star_flower.png';
  static const String plantFern = '$_sprites/plant_fern.png';

  static const String treeApple = '$_sprites/tree_apple.png';
  static const String treeOrange = '$_sprites/tree_orange.png';
  static const String treePear = '$_sprites/tree_pear.png';
  static const String treeFlowering = '$_sprites/tree_flowering.png';

  static const String bushStrawberry = '$_sprites/bush_strawberry.png';
  static const String bushBlueberry = '$_sprites/bush_blueberry.png';
  static const String bushRaspberry = '$_sprites/bush_raspberry.png';
  static const String bushBlackberry = '$_sprites/bush_blackberry.png';

  static const String stoneSmall = '$_sprites/stone_small.png';
  static const String stoneFlat = '$_sprites/stone_flat.png';
  static const String stoneCrystal = '$_sprites/stone_crystal.png';
  static const String stoneGoldVeined = '$_sprites/stone_gold_veined.png';

  static const String crystalBlue = '$_sprites/crystal_blue.png';
  static const String crystalPurple = '$_sprites/crystal_purple.png';
  static const String crystalGold = '$_sprites/crystal_gold.png';
  static const String crystalWhite = '$_sprites/crystal_white.png';

  static const String pathStraight = '$_sprites/path_straight.png';
  static const String pathCorner = '$_sprites/path_corner.png';
  static const String pathT = '$_sprites/path_t.png';
  static const String pathCross = '$_sprites/path_cross.png';

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
