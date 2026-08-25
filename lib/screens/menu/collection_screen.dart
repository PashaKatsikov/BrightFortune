import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../data/bounty_catalog.dart';
import '../../data/enemy_catalog.dart';
import '../../data/tower_catalog.dart';
import '../../models/bounty_def.dart';
import '../../models/enemy_def.dart';
import '../../services/audio_service.dart';
import '../../services/player_progress.dart';
import '../../widgets/game_button.dart';
import '../../widgets/panel_box.dart';
import '../../widgets/resource_badge.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _tab = 0;

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
                        Text('Collection', style: AppText.heading(size: 24)),
                        const Spacer(),
                        CurrencyBar(coins: progress.coins, shards: progress.shards),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: BountyCatalog.all.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => _BountyCard(def: BountyCatalog.all[index], progress: progress),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _TabButton(label: 'Defenses', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                        const SizedBox(width: 10),
                        _TabButton(label: 'Bestiary', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                        const Spacer(),
                        if (_tab == 1)
                          Text(
                            'Discovered ${_discoveredCount(progress)} / ${_allEnemies.length}',
                            style: AppText.body_(size: 12, color: AppColors.textMuted, weight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _tab == 0 ? _towersGrid() : _enemiesGrid(progress),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _towersGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: TowerCatalog.all.length,
      itemBuilder: (context, index) => _EntryCard(
        sprite: TowerCatalog.all[index].sprite,
        name: TowerCatalog.all[index].name,
        unlocked: true,
      ),
    );
  }

  List<EnemyDef> get _allEnemies => [...EnemyCatalog.common, ...EnemyCatalog.special, ...EnemyCatalog.elite, ...EnemyCatalog.boss];

  int _discoveredCount(PlayerProgress progress) => _allEnemies.where((e) => progress.isEnemyDiscovered(e.id)).length;

  Widget _enemiesGrid(PlayerProgress progress) {
    final all = _allEnemies;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: all.length,
      itemBuilder: (context, index) {
        final enemy = all[index];
        final discovered = progress.isEnemyDiscovered(enemy.id);
        return _EntryCard(
          sprite: enemy.sprite,
          name: discovered ? enemy.name : '???',
          unlocked: discovered,
          badge: _categoryLabel(enemy.category),
        );
      },
    );
  }

  String _categoryLabel(EnemyCategory c) {
    switch (c) {
      case EnemyCategory.common:
        return '';
      case EnemyCategory.special:
        return 'Special';
      case EnemyCategory.elite:
        return 'Elite';
      case EnemyCategory.boss:
        return 'Boss';
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldButton : null,
          color: selected ? null : Colors.black26,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.panelBorder : Colors.white24),
        ),
        child: Text(
          label,
          style: AppText.body_(size: 14, color: selected ? const Color(0xFF4A2A00) : Colors.white70, weight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final String sprite;
  final String name;
  final bool unlocked;
  final String badge;

  const _EntryCard({required this.sprite, required this.name, required this.unlocked, this.badge = ''});

  @override
  Widget build(BuildContext context) {
    return PanelBox(
      padding: const EdgeInsets.all(6),
      borderRadius: 14,
      child: Column(
        children: [
          Expanded(
            child: unlocked
                ? Image.asset(sprite, fit: BoxFit.contain)
                : ColorFiltered(
                    colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                    child: Opacity(opacity: 0.55, child: Image.asset(sprite, fit: BoxFit.contain)),
                  ),
          ),
          const SizedBox(height: 4),
          Text(name, style: AppText.body_(size: 10, weight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (badge.isNotEmpty)
            Text(badge, style: AppText.body_(size: 9, color: AppColors.gold)),
        ],
      ),
    );
  }
}

/// One Bestiary completion bounty: shows the permanent bonus it unlocks,
/// discovery progress toward that category, and a Claim button once ready.
class _BountyCard extends StatelessWidget {
  final BountyDef def;
  final PlayerProgress progress;

  const _BountyCard({required this.def, required this.progress});

  @override
  Widget build(BuildContext context) {
    final claimed = progress.isBountyClaimed(def.id);
    final done = progress.bountyProgress(def);
    final total = def.enemies.length;
    final ready = !claimed && done >= total;

    return SizedBox(
      width: 136,
      child: PanelBox(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        borderColor: ready ? AppColors.gold : AppColors.panelBorder.withValues(alpha: claimed ? 0.4 : 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Opacity(
                  opacity: claimed ? 0.6 : 1,
                  child: Image.asset(def.icon, width: 22, height: 22),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    def.bonusLabel,
                    style: AppText.body_(size: 10, weight: FontWeight.w800, color: AppColors.gold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 6,
                backgroundColor: Colors.black45,
                valueColor: AlwaysStoppedAnimation(claimed ? AppColors.green : AppColors.gold),
              ),
            ),
            const SizedBox(height: 6),
            if (claimed)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 14),
                  const SizedBox(width: 4),
                  Text('Claimed', style: AppText.body_(size: 11, color: AppColors.green, weight: FontWeight.w800)),
                ],
              )
            else if (ready)
              GestureDetector(
                onTap: () {
                  AudioService.instance.playSfx(Assets.sfxRewardReceived);
                  progress.claimBounty(def);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(gradient: AppColors.goldButton, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'Claim',
                    textAlign: TextAlign.center,
                    style: AppText.body_(size: 11, color: const Color(0xFF4A2A00), weight: FontWeight.w800),
                  ),
                ),
              )
            else
              Text('$done / $total defeated', style: AppText.body_(size: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
