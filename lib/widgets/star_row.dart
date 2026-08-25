import 'package:flutter/material.dart';

import '../core/colors.dart';

/// Row of three star icons showing the achieved rating (0-3).
class StarRow extends StatelessWidget {
  final int stars;
  final double size;

  const StarRow({super.key, required this.stars, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Icon(
          Icons.star_rounded,
          size: size,
          color: filled ? AppColors.gold : Colors.white24,
          shadows: filled
              ? const [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1))]
              : null,
        );
      }),
    );
  }
}
