import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../game/bright_fortune_game.dart';
import '../../widgets/game_button.dart';
import '../../widgets/panel_box.dart';
import '../../widgets/star_row.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final VoidCallback onSettings;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
          child: SingleChildScrollView(
            child: PanelBox(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Paused', style: AppText.title(size: 26)),
                  const SizedBox(height: 12),
                  GameButton(label: 'Resume', width: 220, height: 48, onPressed: onResume),
                  const SizedBox(height: 10),
                  GameButton(
                    label: 'Settings',
                    width: 220,
                    height: 48,
                    style: GameButtonStyle.purple,
                    onPressed: onSettings,
                  ),
                  const SizedBox(height: 10),
                  GameButton(
                    label: 'Restart Level',
                    width: 220,
                    height: 48,
                    style: GameButtonStyle.purple,
                    onPressed: onRestart,
                  ),
                  const SizedBox(height: 10),
                  GameButton(label: 'Exit', width: 220, height: 48, style: GameButtonStyle.red, onPressed: onExit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VictoryOverlay extends StatelessWidget {
  final BrightFortuneGame game;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const VictoryOverlay({super.key, required this.game, required this.onContinue, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final wallsIntact = game.walls.values.where((w) => !w.isBroken).length;
    var stars = 1;
    if (state.corePercent >= 0.8 && wallsIntact >= 3) {
      stars = 3;
    } else if (state.corePercent >= 0.4 && wallsIntact >= 2) {
      stars = 2;
    }

    return Container(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
          child: SingleChildScrollView(
            child: PanelBox(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3B2470), Color(0xFF1B0F3D)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Victory!', style: AppText.title(size: 30, color: AppColors.gold)),
                  const SizedBox(height: 6),
                  StarRow(stars: stars, size: 30),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(Assets.goldenCoin, width: 24, height: 24),
                      const SizedBox(width: 6),
                      Text('+${state.coinsEarned}', style: AppText.stat(size: 18)),
                      const SizedBox(width: 20),
                      Image.asset(Assets.starShard, width: 24, height: 24),
                      const SizedBox(width: 6),
                      Text('+${state.shardsEarned}', style: AppText.stat(size: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GameButton(label: 'Continue', width: 220, height: 48, onPressed: onContinue),
                  const SizedBox(height: 10),
                  GameButton(
                    label: 'Play Again',
                    width: 220,
                    height: 48,
                    style: GameButtonStyle.purple,
                    onPressed: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DefeatOverlay extends StatelessWidget {
  final BrightFortuneGame game;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const DefeatOverlay({super.key, required this.game, required this.onRetry, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    return Container(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
          child: SingleChildScrollView(
            child: PanelBox(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Defeat', style: AppText.title(size: 28, color: AppColors.red)),
                  const SizedBox(height: 6),
                  Text('The Star Core has fallen.', style: AppText.body_(size: 14, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(Assets.goldenCoin, width: 20, height: 20),
                      const SizedBox(width: 6),
                      Text('+${state.coinsEarned}', style: AppText.stat(size: 16)),
                      const SizedBox(width: 16),
                      Image.asset(Assets.starShard, width: 20, height: 20),
                      const SizedBox(width: 6),
                      Text('+${state.shardsEarned}', style: AppText.stat(size: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GameButton(label: 'Retry', width: 220, height: 48, onPressed: onRetry),
                  const SizedBox(height: 10),
                  GameButton(label: 'Exit', width: 220, height: 48, style: GameButtonStyle.purple, onPressed: onExit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
