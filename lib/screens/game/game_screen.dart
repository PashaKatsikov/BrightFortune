import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../data/wave_generator.dart';
import '../../game/bright_fortune_game.dart';
import '../../models/location_def.dart';
import '../../services/audio_service.dart';
import '../menu/settings_screen.dart';
import 'end_overlays.dart';
import 'game_hud.dart';

class GameScreen extends StatefulWidget {
  final LocationDef location;
  final int levelIndex;

  const GameScreen({super.key, required this.location, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BrightFortuneGame _game;
  bool _paused = false;
  bool _ended = false;
  bool _victory = false;

  @override
  void initState() {
    super.initState();
    _createGame();
  }

  void _createGame() {
    final waves = WaveGenerator.generate(widget.location, widget.levelIndex);
    _game = BrightFortuneGame(location: widget.location, levelIndex: widget.levelIndex, waves: waves);
    _game.onGameEnded = (victory) {
      if (!mounted) return;
      setState(() {
        _ended = true;
        _victory = victory;
      });
    };
  }

  void _togglePause() {
    if (_ended) return;
    AudioService.instance.playSfx(Assets.sfxMenuOpen);
    setState(() {
      _paused = !_paused;
      if (_paused) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });
  }

  void _restart() {
    setState(() {
      _paused = false;
      _ended = false;
      _victory = false;
      _createGame();
    });
  }

  void _exitToLevels() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_ended) {
          Navigator.of(context).pop();
        } else {
          _togglePause();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget(game: _game),
            GameHud(game: _game, onPause: _togglePause),
            if (_paused && !_ended)
              PauseOverlay(
                onResume: _togglePause,
                onRestart: _restart,
                onExit: _exitToLevels,
                onSettings: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            if (_ended && _victory)
              VictoryOverlay(game: _game, onContinue: _exitToLevels, onRetry: _restart),
            if (_ended && !_victory)
              DefeatOverlay(game: _game, onRetry: _restart, onExit: _exitToLevels),
          ],
        ),
      ),
    );
  }
}
