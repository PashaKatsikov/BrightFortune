import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../data/upgrade_catalog.dart';
import '../../models/upgrade_def.dart';
import '../../services/player_progress.dart';
import '../../widgets/game_button.dart';
import '../../widgets/panel_box.dart';
import '../../widgets/resource_badge.dart';

class UpgradesScreen extends StatelessWidget {
  const UpgradesScreen({super.key});

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
                        Text('Defense Upgrades', style: AppText.heading(size: 24)),
                        const Spacer(),
                        CurrencyBar(coins: progress.coins, shards: progress.shards),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3.6,
                      ),
                      itemCount: UpgradeCatalog.all.length,
                      itemBuilder: (context, index) {
                        final def = UpgradeCatalog.all[index];
                        return _UpgradeTile(def: def, progress: progress);
                      },
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

class _UpgradeTile extends StatelessWidget {
  final UpgradeDef def;
  final PlayerProgress progress;

  const _UpgradeTile({required this.def, required this.progress});

  @override
  Widget build(BuildContext context) {
    final level = progress.upgradeLevel(def.type);
    final maxed = level >= def.maxLevel;
    final cost = maxed ? 0 : def.costForLevel(level);
    final canAfford = progress.canAffordUpgrade(def.type);

    return PanelBox(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(def.icon, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(def.name, style: AppText.body_(size: 14, weight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  'Lv $level/${def.maxLevel} · +${(level * def.perLevelBonus).toStringAsFixed(0)}${def.unit}',
                  style: AppText.body_(size: 11, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: level / def.maxLevel,
                    minHeight: 5,
                    backgroundColor: Colors.black38,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: maxed
                ? const _MaxedBadge()
                : GameButton(
                    label: '$cost',
                    icon: def.currency == UpgradeCurrency.coins ? null : Icons.diamond_rounded,
                    height: 40,
                    width: 96,
                    fontSize: 14,
                    onPressed: canAfford ? () => progress.purchaseUpgrade(def.type) : null,
                  ),
          ),
        ],
      ),
    );
  }
}

class _MaxedBadge extends StatelessWidget {
  const _MaxedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green),
      ),
      child: Text('MAX', style: AppText.body_(size: 13, color: AppColors.green, weight: FontWeight.w800)),
    );
  }
}
