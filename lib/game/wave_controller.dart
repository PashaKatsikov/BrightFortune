import '../core/assets.dart';
import '../data/enemy_catalog.dart';
import '../models/wave_def.dart';
import '../services/audio_service.dart';
import 'bright_fortune_game.dart';
import 'components/enemy_component.dart';

/// Drives the level's 7-wave structure: schedules enemy spawns, shows the
/// Golden Bell warning ahead of dangerous waves, waits for waves to clear,
/// and reports level completion back to the game.
class WaveController {
  final BrightFortuneGame game;
  final List<WaveDef> waves;

  int _waveIndex = -1;
  double _waveClock = 0;
  int _spawnCursor = 0;
  bool _warningFired = false;
  bool _finished = false;

  WaveController({required this.game, required this.waves});

  WaveDef? get _current => (_waveIndex >= 0 && _waveIndex < waves.length) ? waves[_waveIndex] : null;

  void start() {
    _beginIntermission(initial: true);
  }

  void _beginIntermission({bool initial = false}) {
    game.state.intermission = true;
    game.state.intermissionRemaining = initial ? 2.5 : 3.5;
    game.state.waveActive = false;
    _warningFired = false;
  }

  void update(double dt) {
    if (_finished || game.state.gameOver) return;

    if (game.state.intermission) {
      game.state.intermissionRemaining -= dt;
      final next = waves[(_waveIndex + 1).clamp(0, waves.length - 1)];
      if (!_warningFired && next.isDangerous && game.state.intermissionRemaining <= next.warningLeadTime) {
        _warningFired = true;
        game.showBellWarning('Wave ${next.number} incoming!');
        AudioService.instance.playSfx(Assets.sfxBellWarning);
      }
      if (game.state.intermissionRemaining <= 0) {
        _startNextWave();
      }
      return;
    }

    final wave = _current;
    if (wave == null) return;

    _waveClock += dt;
    while (_spawnCursor < wave.spawns.length && wave.spawns[_spawnCursor].timeOffset <= _waveClock) {
      final spawn = wave.spawns[_spawnCursor];
      _spawnCursor++;
      final def = EnemyCatalog.byId[spawn.enemyId];
      if (def == null) continue;
      final enemy = EnemyComponent(
        def: def,
        lane: spawn.lane,
        game: game,
        hpMultiplier: spawn.hpMultiplier,
        speedMultiplier: spawn.speedMultiplier,
      );
      game.spawnEnemy(enemy);
      game.state.enemiesAliveInWave++;
    }

    final allSpawned = _spawnCursor >= wave.spawns.length;
    if (allSpawned && game.state.enemiesAliveInWave <= 0) {
      _completeWave();
    }
  }

  void _startNextWave() {
    _waveIndex++;
    _spawnCursor = 0;
    _waveClock = 0;
    game.state.waveNumber = _waveIndex + 1;
    game.state.intermission = false;
    game.state.waveActive = true;
    game.state.enemiesAliveInWave = 0;
    game.onWaveStarted(_waveIndex + 1);
  }

  void _completeWave() {
    game.state.waveActive = false;
    game.onWaveCleared(_waveIndex + 1);
    if (_waveIndex + 1 >= waves.length) {
      _finished = true;
      game.onLevelVictory();
    } else {
      _beginIntermission();
    }
  }
}
