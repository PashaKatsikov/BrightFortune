import 'package:audioplayers/audioplayers.dart';

/// Wraps audioplayers to provide a single looping music channel and a small
/// pool of low-latency channels for short sound effects, both respecting the
/// user's volume / mute settings.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _music = AudioPlayer(playerId: 'bf_music');
  final List<AudioPlayer> _sfxPool =
      List.generate(6, (i) => AudioPlayer(playerId: 'bf_sfx_$i'));
  int _sfxIndex = 0;

  double musicVolume = 0.6;
  double sfxVolume = 0.85;
  bool musicEnabled = true;
  bool sfxEnabled = true;
  bool _initialized = false;
  String? _currentMusic;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _music.setReleaseMode(ReleaseMode.loop);
    for (final p in _sfxPool) {
      await p.setPlayerMode(PlayerMode.lowLatency);
      await p.setReleaseMode(ReleaseMode.stop);
    }
  }

  String _stripAssets(String path) =>
      path.startsWith('assets/') ? path.substring('assets/'.length) : path;

  Future<void> playMusic(String assetPath, {bool restart = false}) async {
    if (!restart && _currentMusic == assetPath) return;
    _currentMusic = assetPath;
    if (!musicEnabled) return;
    try {
      await _music.stop();
      await _music.setVolume(musicVolume);
      await _music.play(AssetSource(_stripAssets(assetPath)));
    } catch (_) {
      // Ignore playback errors (e.g. missing codec on desktop test devices).
    }
  }

  Future<void> stopMusic() async {
    _currentMusic = null;
    await _music.stop();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled = enabled;
    if (!enabled) {
      await _music.stop();
    } else if (_currentMusic != null) {
      await playMusic(_currentMusic!, restart: true);
    }
  }

  Future<void> setMusicVolume(double volume) async {
    musicVolume = volume;
    await _music.setVolume(volume);
  }

  void setSfxEnabled(bool enabled) => sfxEnabled = enabled;
  void setSfxVolume(double volume) => sfxVolume = volume;

  Future<void> playSfx(String assetPath) async {
    if (!sfxEnabled) return;
    final player = _sfxPool[_sfxIndex];
    _sfxIndex = (_sfxIndex + 1) % _sfxPool.length;
    try {
      await player.stop();
      await player.setVolume(sfxVolume);
      await player.play(AssetSource(_stripAssets(assetPath)));
    } catch (_) {
      // Ignore - sound effects should never crash gameplay.
    }
  }
}
