import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../data/enemy_catalog.dart';
import '../../data/tower_catalog.dart';
import '../../models/enemy_def.dart';
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _TabButton(label: 'Defenses', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                        const SizedBox(width: 10),
                        _TabButton(label: 'Bestiary', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
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

  Widget _enemiesGrid(PlayerProgress progress) {
    final all = [...EnemyCatalog.common, ...EnemyCatalog.special, ...EnemyCatalog.elite, ...EnemyCatalog.boss];
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
