import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../models/location_def.dart';
import '../../services/player_progress.dart';
import '../../widgets/game_button.dart';
import '../../widgets/panel_box.dart';
import '../../widgets/resource_badge.dart';
import '../../widgets/star_row.dart';
import '../game/game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  final LocationDef location;

  const LevelSelectScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(location.background, fit: BoxFit.cover),
          Container(color: AppColors.backgroundDeep.withValues(alpha: 0.6)),
          SafeArea(
            child: ListenableBuilder(
              listenable: PlayerProgress.instance,
              builder: (context, _) {
                final progress = PlayerProgress.instance;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          GameIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).pop()),
                          const SizedBox(width: 12),
                          Text(location.name, style: AppText.heading(size: 24)),
                          const Spacer(),
                          CurrencyBar(coins: progress.coins, shards: progress.shards),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.05,
                          ),
                          itemCount: location.levelCount,
                          itemBuilder: (context, index) {
                            final unlocked = progress.isLevelUnlocked(location.index, index);
                            final stars = progress.starsFor(location.index, index);
                            return _LevelTile(
                              levelNumber: index + 1,
                              unlocked: unlocked,
                              stars: stars,
                              onTap: unlocked
                                  ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => GameScreen(location: location, levelIndex: index),
                                        ),
                                      )
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int levelNumber;
  final bool unlocked;
  final int stars;
  final VoidCallback? onTap;

  const _LevelTile({required this.levelNumber, required this.unlocked, required this.stars, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PanelBox(
        padding: const EdgeInsets.all(6),
        borderRadius: 16,
        gradient: unlocked ? AppColors.panelGradient : null,
        borderColor: unlocked ? AppColors.panelBorder : Colors.white24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: unlocked
                    ? Text('$levelNumber', style: AppText.title(size: 28))
                    : const Icon(Icons.lock_rounded, color: Colors.white38, size: 26),
              ),
            ),
            if (unlocked) StarRow(stars: stars, size: 13),
          ],
        ),
      ),
    );
  }
}
