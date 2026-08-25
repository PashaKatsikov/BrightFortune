import 'package:flutter/material.dart';

/// Bright Fortune palette - Premium Casual Stylized style:
/// bright gold, white, yellow, rich green, red, orange, blue, purple.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF1A1036);
  static const Color backgroundDeep = Color(0xFF0F0A24);
  static const Color panel = Color(0xFF2B1B54);
  static const Color panelLight = Color(0xFF3B2470);
  static const Color panelBorder = Color(0xFFFFD874);

  static const Color gold = Color(0xFFFFC94A);
  static const Color goldDeep = Color(0xFFE79A1C);
  static const Color goldLight = Color(0xFFFFF0B8);

  static const Color purple = Color(0xFF8B4FE0);
  static const Color purpleDeep = Color(0xFF5B2CA0);

  static const Color blue = Color(0xFF3FB6FF);
  static const Color blueDeep = Color(0xFF1E6FBF);

  static const Color green = Color(0xFF4CC96B);
  static const Color greenDeep = Color(0xFF2C8F49);

  static const Color red = Color(0xFFE84C4C);
  static const Color redDeep = Color(0xFFB22E2E);

  static const Color orange = Color(0xFFFF9A3C);

  static const Color energyGold = Color(0xFFFFF3C4);
  static const Color energyBlue = Color(0xFF7FD9FF);
  static const Color energyPurple = Color(0xFFC79BFF);

  static const Color textLight = Color(0xFFFFF6E0);
  static const Color textMuted = Color(0xFFC9B8E8);

  static const LinearGradient goldButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE9A8), Color(0xFFFFC94A), Color(0xFFE79A1C)],
  );

  static const LinearGradient purpleButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB88CFF), Color(0xFF8B4FE0), Color(0xFF5B2CA0)],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3B2470), Color(0xFF221249)],
  );

  static const LinearGradient skyBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF241452), Color(0xFF120A2E), Color(0xFF0A0620)],
  );
}
