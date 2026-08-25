import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text_styles.dart';
import '../services/audio_service.dart';
import '../core/assets.dart';

enum GameButtonStyle { gold, purple, red, green }

/// A stylized pill-shaped button with a subtle press animation, matching
/// the game's Premium Casual gold/purple visual language.
class GameButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final GameButtonStyle style;
  final double width;
  final double height;
  final IconData? icon;
  final double fontSize;

  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = GameButtonStyle.gold,
    this.width = 220,
    this.height = 62,
    this.icon,
    this.fontSize = 22,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _pressed = false;

  Gradient get _gradient {
    switch (widget.style) {
      case GameButtonStyle.gold:
        return AppColors.goldButton;
      case GameButtonStyle.purple:
        return AppColors.purpleButton;
      case GameButtonStyle.red:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8A7A), Color(0xFFE84C4C), Color(0xFF9E2A2A)],
        );
      case GameButtonStyle.green:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8CE7A0), Color(0xFF4CC96B), Color(0xFF287A3D)],
        );
    }
  }

  Color get _textColor {
    switch (widget.style) {
      case GameButtonStyle.gold:
        return const Color(0xFF4A2A00);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              AudioService.instance.playSfx(Assets.sfxButtonClick);
              widget.onPressed?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: _textColor, size: widget.fontSize),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.button(size: widget.fontSize, color: _textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small circular icon-only button variant (used for back / pause / close).
class GameIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final GameButtonStyle style;

  const GameIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.style = GameButtonStyle.purple,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed == null
          ? null
          : () {
              AudioService.instance.playSfx(Assets.sfxButtonClick);
              onPressed?.call();
            },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: style == GameButtonStyle.gold ? AppColors.goldButton : AppColors.purpleButton,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
