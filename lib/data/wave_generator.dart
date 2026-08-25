import 'dart:math';

import '../models/enemy_def.dart';
import '../models/location_def.dart';
import '../models/wave_def.dart';
import 'enemy_catalog.dart';

/// Procedurally builds the 7-wave structure for a given location + level,
/// following the difficulty curve described in the design document:
/// early waves are slow and forgiving, later waves mix enemy types and
/// ramp up pressure, and wave 7 is the toughest of the level.
class WaveGenerator {
  WaveGenerator._();

  static List<WaveDef> generate(LocationDef location, int levelIndex) {
    final globalDifficulty = location.index * 15 + levelIndex; // 0..74
    final isLastLevelOfLocation = levelIndex == location.levelCount - 1;
    final rand = Random(location.index * 1000 + levelIndex);

    final hpMult = 1 + globalDifficulty * 0.05;
    final speedMult = 1 + globalDifficulty * 0.008;

    final pools = _buildPools(location);

    final waves = <WaveDef>[];
    for (var w = 1; w <= 7; w++) {
      waves.add(_buildWave(
        waveNumber: w,
        location: location,
        pools: pools,
        hpMult: hpMult,
        speedMult: speedMult,
        rand: rand,
        isFinalWaveOfLevel: w == 7,
        spawnBoss: w == 7 && isLastLevelOfLocation && pools.boss.isNotEmpty,
      ));
    }
    return waves;
  }

  static _Pools _buildPools(LocationDef location) {
    return _Pools(
      common: EnemyCatalog.common,
      special: location.unlockedCategories.contains(EnemyCategory.special) ? EnemyCatalog.special : const [],
      elite: location.unlockedCategories.contains(EnemyCategory.elite) ? EnemyCatalog.elite : const [],
      boss: location.unlockedCategories.contains(EnemyCategory.boss) ? EnemyCatalog.boss : const [],
    );
  }

  static WaveDef _buildWave({
    required int waveNumber,
    required LocationDef location,
    required _Pools pools,
    required double hpMult,
    required double speedMult,
    required Random rand,
    required bool isFinalWaveOfLevel,
    required bool spawnBoss,
  }) {
    // Wave progress 0..1 across the 7 waves, used to blend enemy composition.
    final progress = (waveNumber - 1) / 6.0;

    final baseCount = 5 + waveNumber * 2;
    final totalEnemies = baseCount + (waveNumber >= 5 ? waveNumber : 0);

    final useSpecial = pools.special.isNotEmpty && waveNumber >= 3;
    final useElite = pools.elite.isNotEmpty && waveNumber >= 6;

    final spawns = <SpawnEvent>[];
    final lanes = Lane.values;
    var laneCursor = rand.nextInt(4);

    final spawnInterval = max(0.32, 1.05 - progress * 0.55 - location.index * 0.02);
    var t = 0.0;

    for (var i = 0; i < totalEnemies; i++) {
      final roll = rand.nextDouble();
      EnemyDef enemy;
      if (useElite && roll < 0.12 + progress * 0.08) {
        enemy = pools.elite[rand.nextInt(pools.elite.length)];
      } else if (useSpecial && roll < 0.45 + progress * 0.1) {
        enemy = pools.special[rand.nextInt(pools.special.length)];
      } else {
        enemy = pools.common[rand.nextInt(pools.common.length)];
      }

      final lane = lanes[laneCursor % 4];
      laneCursor++;

      spawns.add(SpawnEvent(
        enemyId: enemy.id,
        lane: lane,
        timeOffset: t,
        hpMultiplier: hpMult,
        speedMultiplier: speedMult,
      ));
      t += spawnInterval * (0.85 + rand.nextDouble() * 0.3);
    }

    if (spawnBoss) {
      final boss = pools.boss[0];
      spawns.add(SpawnEvent(
        enemyId: boss.id,
        lane: Lane.north,
        timeOffset: t + 2.5,
        hpMultiplier: 1 + location.index * 0.4,
        speedMultiplier: 1,
      ));
    }

    final isDangerous = waveNumber >= 5 || useElite || spawnBoss;

    return WaveDef(number: waveNumber, spawns: spawns, isDangerous: isDangerous);
  }
}

class _Pools {
  final List<EnemyDef> common;
  final List<EnemyDef> special;
  final List<EnemyDef> elite;
  final List<EnemyDef> boss;

  const _Pools({required this.common, required this.special, required this.elite, required this.boss});
}
