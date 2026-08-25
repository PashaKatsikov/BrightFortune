import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../data/location_catalog.dart';
import '../../models/location_def.dart';
import '../../services/player_progress.dart';
import '../../widgets/game_button.dart';
import '../../widgets/panel_box.dart';
import '../../widgets/resource_badge.dart';
import 'level_select_screen.dart';

class LocationSelectScreen extends StatelessWidget {
  const LocationSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.skyBackground),
        child: SafeArea(
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
                        Text('Choose Your Garden', style: AppText.heading(size: 24)),
                        const Spacer(),
                        CurrencyBar(coins: progress.coins, shards: progress.shards),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: LocationCatalog.all.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 18),
                        itemBuilder: (context, index) {
                          final loc = LocationCatalog.all[index];
                          final unlocked = progress.isLocationUnlocked(loc.index);
                          final completed = progress.completedLevelsIn(loc.index);
                          return _LocationCard(location: loc, unlocked: unlocked, completed: completed);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationDef location;
  final bool unlocked;
  final int completed;

  const _LocationCard({required this.location, required this.unlocked, required this.completed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: PanelBox(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: unlocked
                          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                          : const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                      child: Image.asset(location.background, fit: BoxFit.cover),
                    ),
                    if (!unlocked)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(
                          child: Icon(Icons.lock_rounded, color: Colors.white70, size: 40),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(location.name, style: AppText.heading(size: 20), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              unlocked ? '$completed / ${location.levelCount} levels cleared' : 'Complete the previous garden to unlock',
              style: AppText.body_(size: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            GameButton(
              label: unlocked ? 'Enter' : 'Locked',
              height: 44,
              width: double.infinity,
              fontSize: 16,
              style: unlocked ? GameButtonStyle.gold : GameButtonStyle.purple,
              onPressed: unlocked
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LevelSelectScreen(location: location)),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
