import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../services/player_progress.dart';
import '../../widgets/game_button.dart';
import '../../widgets/resource_badge.dart';
import 'collection_screen.dart';
import 'location_select_screen.dart';
import 'settings_screen.dart';
import 'upgrades_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: PlayerProgress.instance,
        builder: (context, _) {
          final progress = PlayerProgress.instance;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(Assets.bgBrightGarden, fit: BoxFit.cover),
              Container(color: AppColors.backgroundDeep.withValues(alpha: 0.55)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CurrencyBar(coins: progress.coins, shards: progress.shards),
                          const Spacer(),
                          GameIconButton(
                            icon: Icons.settings_rounded,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Image.asset(
                                    Assets.brightKeeper,
                                    height: 190,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(Assets.gameName, height: 150),
                                      const SizedBox(height: 22),
                                      GameButton(
                                        label: 'PLAY',
                                        width: 240,
                                        height: 68,
                                        fontSize: 26,
                                        icon: Icons.play_arrow_rounded,
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const LocationSelectScreen()),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GameButton(
                                            label: 'Collection',
                                            style: GameButtonStyle.purple,
                                            width: 150,
                                            height: 46,
                                            fontSize: 16,
                                            onPressed: () => Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => const CollectionScreen()),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          GameButton(
                                            label: 'Upgrades',
                                            style: GameButtonStyle.purple,
                                            width: 150,
                                            height: 46,
                                            fontSize: 16,
                                            onPressed: () => Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => const UpgradesScreen()),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
