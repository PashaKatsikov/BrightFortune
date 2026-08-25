import 'package:flutter/material.dart';

import '../core/assets.dart';
import '../core/text_styles.dart';
import 'panel_box.dart';

/// Small pill showing an icon (coin / shard / heart) and a numeric value,
/// used in the top bar of most menu screens and the in-game HUD.
class ResourceBadge extends StatelessWidget {
  final String iconAsset;
  final String value;
  final Color? valueColor;

  const ResourceBadge({super.key, required this.iconAsset, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return PanelBox(
      borderRadius: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconAsset, width: 26, height: 26),
          const SizedBox(width: 6),
          Text(value, style: AppText.stat(size: 16, color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }
}

class CurrencyBar extends StatelessWidget {
  final int coins;
  final int shards;

  const CurrencyBar({super.key, required this.coins, required this.shards});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResourceBadge(iconAsset: Assets.goldenCoin, value: '$coins'),
        const SizedBox(width: 10),
        ResourceBadge(iconAsset: Assets.starShard, value: '$shards'),
      ],
    );
  }
}
