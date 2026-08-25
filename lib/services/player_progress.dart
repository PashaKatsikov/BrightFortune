import 'package:flutter/foundation.dart';

import '../data/location_catalog.dart';
import '../data/upgrade_catalog.dart';
import '../models/upgrade_def.dart';
import 'audio_service.dart';
import 'storage_service.dart';

enum GraphicsQuality { medium, high }

/// Holds all persisted player state: currencies, upgrade levels, level
/// completion / stars, discovered enemies (collection) and settings.
/// Exposed as a singleton ChangeNotifier so any widget can listen for
/// updates without extra state-management dependencies.
class PlayerProgress extends ChangeNotifier {
  PlayerProgress._internal();
  static final PlayerProgress instance = PlayerProgress._internal();

  final StorageService _storage = StorageService();

  int coins = 0;
  int shards = 0;
  final Map<UpgradeType, int> upgradeLevels = {for (final u in UpgradeType.values) u: 0};
  final Map<String, int> levelStars = {}; // "loc_level" -> stars(1-3)
  final Set<String> defeatedEnemies = {};

  double musicVolume = 0.6;
  double sfxVolume = 0.85;
  bool musicOn = true;
  bool sfxOn = true;
  bool vibrationOn = true;
  GraphicsQuality quality = GraphicsQuality.high;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final data = await _storage.load();
    coins = (data['coins'] as num?)?.toInt() ?? 380;
    shards = (data['shards'] as num?)?.toInt() ?? 15;

    final upgrades = data['upgrades'] as Map<String, dynamic>?;
    if (upgrades != null) {
      for (final entry in upgrades.entries) {
        final type = UpgradeType.values.where((t) => t.name == entry.key).firstOrNull;
        if (type != null) upgradeLevels[type] = (entry.value as num).toInt();
      }
    }

    final stars = data['levelStars'] as Map<String, dynamic>?;
    if (stars != null) {
      levelStars.addAll(stars.map((k, v) => MapEntry(k, (v as num).toInt())));
    }

    final defeated = data['defeatedEnemies'] as List<dynamic>?;
    if (defeated != null) {
      defeatedEnemies.addAll(defeated.map((e) => e.toString()));
    }

    final settings = data['settings'] as Map<String, dynamic>?;
    if (settings != null) {
      musicVolume = (settings['music'] as num?)?.toDouble() ?? musicVolume;
      sfxVolume = (settings['sfx'] as num?)?.toDouble() ?? sfxVolume;
      musicOn = settings['musicOn'] as bool? ?? true;
      sfxOn = settings['sfxOn'] as bool? ?? true;
      vibrationOn = settings['vibration'] as bool? ?? true;
      quality = (settings['quality'] as String?) == 'medium' ? GraphicsQuality.medium : GraphicsQuality.high;
    }

    AudioService.instance
      ..musicVolume = musicVolume
      ..sfxVolume = sfxVolume
      ..musicEnabled = musicOn
      ..sfxEnabled = sfxOn;

    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.save({
      'coins': coins,
      'shards': shards,
      'upgrades': upgradeLevels.map((k, v) => MapEntry(k.name, v)),
      'levelStars': levelStars,
      'defeatedEnemies': defeatedEnemies.toList(),
      'settings': {
        'music': musicVolume,
        'sfx': sfxVolume,
        'musicOn': musicOn,
        'sfxOn': sfxOn,
        'vibration': vibrationOn,
        'quality': quality == GraphicsQuality.medium ? 'medium' : 'high',
      },
    });
  }

  // ---------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------
  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
    _persist();
  }

  void addShards(int amount) {
    shards += amount;
    notifyListeners();
    _persist();
  }

  bool spendCoins(int amount) {
    if (coins < amount) return false;
    coins -= amount;
    notifyListeners();
    _persist();
    return true;
  }

  bool spendShards(int amount) {
    if (shards < amount) return false;
    shards -= amount;
    notifyListeners();
    _persist();
    return true;
  }

  // ---------------------------------------------------------------------
  // Upgrades
  // ---------------------------------------------------------------------
  int upgradeLevel(UpgradeType type) => upgradeLevels[type] ?? 0;

  double upgradeBonus(UpgradeType type) {
    final def = UpgradeCatalog.byType[type]!;
    return upgradeLevel(type) * def.perLevelBonus / 100.0;
  }

  bool canAffordUpgrade(UpgradeType type) {
    final def = UpgradeCatalog.byType[type]!;
    final level = upgradeLevel(type);
    if (level >= def.maxLevel) return false;
    final cost = def.costForLevel(level);
    return def.currency == UpgradeCurrency.coins ? coins >= cost : shards >= cost;
  }

  bool purchaseUpgrade(UpgradeType type) {
    final def = UpgradeCatalog.byType[type]!;
    final level = upgradeLevel(type);
    if (level >= def.maxLevel) return false;
    final cost = def.costForLevel(level);
    final spent = def.currency == UpgradeCurrency.coins ? spendCoins(cost) : spendShards(cost);
    if (!spent) return false;
    upgradeLevels[type] = level + 1;
    notifyListeners();
    _persist();
    return true;
  }

  // ---------------------------------------------------------------------
  // Level progression
  // ---------------------------------------------------------------------
  String _key(int loc, int lvl) => '${loc}_$lvl';

  int starsFor(int loc, int lvl) => levelStars[_key(loc, lvl)] ?? 0;

  bool isLevelUnlocked(int loc, int lvl) {
    if (lvl == 0) return isLocationUnlocked(loc);
    return levelStars.containsKey(_key(loc, lvl - 1));
  }

  bool isLocationUnlocked(int loc) {
    if (loc == 0) return true;
    final prevLocation = LocationCatalog.byIndex(loc - 1);
    return levelStars.containsKey(_key(loc - 1, prevLocation.levelCount - 1));
  }

  int completedLevelsIn(int loc) {
    final location = LocationCatalog.byIndex(loc);
    var count = 0;
    for (var i = 0; i < location.levelCount; i++) {
      if (levelStars.containsKey(_key(loc, i))) count++;
    }
    return count;
  }

  void reportLevelResult(int loc, int lvl, int stars) {
    final key = _key(loc, lvl);
    final prev = levelStars[key] ?? 0;
    if (stars > prev) {
      levelStars[key] = stars;
    }
    notifyListeners();
    _persist();
  }

  // ---------------------------------------------------------------------
  // Collection
  // ---------------------------------------------------------------------
  void markEnemyDefeated(String enemyId) {
    if (defeatedEnemies.add(enemyId)) {
      notifyListeners();
      _persist();
    }
  }

  bool isEnemyDiscovered(String enemyId) => defeatedEnemies.contains(enemyId);

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------
  void setMusicVolume(double v) {
    musicVolume = v;
    AudioService.instance.setMusicVolume(v);
    notifyListeners();
    _persist();
  }

  void setSfxVolume(double v) {
    sfxVolume = v;
    AudioService.instance.setSfxVolume(v);
    notifyListeners();
    _persist();
  }

  void setMusicOn(bool v) {
    musicOn = v;
    AudioService.instance.setMusicEnabled(v);
    notifyListeners();
    _persist();
  }

  void setSfxOn(bool v) {
    sfxOn = v;
    AudioService.instance.setSfxEnabled(v);
    notifyListeners();
    _persist();
  }

  void setVibrationOn(bool v) {
    vibrationOn = v;
    notifyListeners();
    _persist();
  }

  void setQuality(GraphicsQuality q) {
    quality = q;
    notifyListeners();
    _persist();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
