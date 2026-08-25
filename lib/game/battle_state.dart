import '../models/tower_def.dart';
import '../models/wave_def.dart';

enum BuffType { towerDamage, energyRegen, enemySlow, coreBoost, attackSpeed, repairSpeed, burstChargeRate, wallShield }

class ActiveBuff {
  final BuffType type;
  final double magnitude;
  double remaining;

  ActiveBuff({required this.type, required this.magnitude, required this.remaining});
}

/// All mutable runtime state for a single battle. Plain fields (no
/// ChangeNotifier) - the HUD polls this via a lightweight periodic timer to
/// avoid coupling Flutter's build system to Flame's 60fps update loop.
class BattleState {
  double coreHp;
  double coreMaxHp;

  double energy;
  double energyMax;
  double baseEnergyRegenPerSec;

  TowerKind? focusedTower;
  bool boostSuppressed = false;

  double burstCharge = 0;
  double burstMax = 100;
  double baseBurstChargeRatePerSec;

  final Map<Lane, double> wallHp;
  final Map<Lane, double> wallMaxHp;

  int waveNumber = 0;
  int totalWaves = 7;
  int enemiesAliveInWave = 0;
  bool waveActive = false;
  bool intermission = true;
  double intermissionRemaining = 3;
  bool waveWarningShown = false;
  String? pendingWarningWaveLabel;

  int coinsEarned = 0;
  int shardsEarned = 0;

  bool gameOver = false;
  bool victory = false;
  bool paused = false;

  final List<ActiveBuff> activeBuffs = [];

  double elapsedSeconds = 0;

  BattleState({
    required this.coreMaxHp,
    required this.energyMax,
    required this.baseEnergyRegenPerSec,
    required this.baseBurstChargeRatePerSec,
    required Map<Lane, double> initialWallHp,
  })  : coreHp = coreMaxHp,
        energy = energyMax * 0.6,
        wallHp = Map.of(initialWallHp),
        wallMaxHp = Map.of(initialWallHp);

  double get corePercent => (coreHp / coreMaxHp).clamp(0.0, 1);
  double get energyPercent => (energy / energyMax).clamp(0.0, 1);
  double get burstPercent => (burstCharge / burstMax).clamp(0.0, 1);

  double buffMultiplier(BuffType type) {
    double mult = 1;
    for (final b in activeBuffs) {
      if (b.type == type) mult += b.magnitude;
    }
    return mult;
  }

  /// Fraction of incoming wall damage currently blocked by active Shield
  /// Chime blessings (0 = no protection, capped well short of full immunity).
  double get wallShieldReduction {
    double total = 0;
    for (final b in activeBuffs) {
      if (b.type == BuffType.wallShield) total += b.magnitude;
    }
    return total.clamp(0.0, 0.85);
  }

  void addBuff(BuffType type, double magnitude, double duration) {
    activeBuffs.add(ActiveBuff(type: type, magnitude: magnitude, remaining: duration));
  }

  void tickBuffs(double dt) {
    activeBuffs.removeWhere((b) {
      b.remaining -= dt;
      return b.remaining <= 0;
    });
  }
}
