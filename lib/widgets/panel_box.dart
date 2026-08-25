import 'package:flutter/material.dart';

import '../core/colors.dart';

/// A rounded gradient panel with a gold border, used as the base container
/// for menu cards, dialogs and HUD panels throughout the game.
class PanelBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final Color borderColor;
  final double borderWidth;

  const PanelBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.gradient,
    this.borderColor = AppColors.panelBorder,
    this.borderWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.panelGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}
