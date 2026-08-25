import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized text styles using the game's two font families:
/// Baloo2 for display / headings, Nunito for body text.
class AppText {
  AppText._();

  static const String display = 'Baloo2';
  static const String body = 'Nunito';

  static TextStyle title({double size = 40, Color color = AppColors.gold}) {
    return TextStyle(
      fontFamily: display,
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      shadows: const [
        Shadow(color: Colors.black87, offset: Offset(0, 3), blurRadius: 6),
      ],
    );
  }

  static TextStyle heading({double size = 26, Color color = AppColors.textLight}) {
    return TextStyle(
      fontFamily: display,
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      shadows: const [
        Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4),
      ],
    );
  }

  static TextStyle button({double size = 22, Color color = const Color(0xFF4A2A00)}) {
    return TextStyle(
      fontFamily: display,
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.5,
    );
  }

  static TextStyle body_({double size = 16, Color color = AppColors.textLight, FontWeight weight = FontWeight.w600}) {
    return TextStyle(
      fontFamily: body,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle stat({double size = 18, Color color = AppColors.textLight}) {
    return TextStyle(
      fontFamily: body,
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      shadows: const [
        Shadow(color: Colors.black87, offset: Offset(0, 1), blurRadius: 3),
      ],
    );
  }
}
