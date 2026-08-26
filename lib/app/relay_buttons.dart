import 'package:flutter/material.dart';

/// Buttons for the shell surfaces (boot / offline / push invite).
///
/// Deliberately a separate implementation from `lib/widgets/game_button.dart`
/// so the shell never imports the game's widget tree. Both variants are real
/// gradient pills: the "Skip" affordance must never be a low-contrast text
/// link (see .cursor/rules/gray_part_pitfalls.md §12), so weight comes from
/// size and position instead of opacity.
enum RelayButtonTone { gold, plum }

class RelayPillButton extends StatefulWidget {
  const RelayPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.tone = RelayButtonTone.gold,
    this.compact = false,
    this.width,
    this.height,
  });

  final String label;
  final VoidCallback onTap;
  final RelayButtonTone tone;
  final bool compact;
  final double? width;

  /// Overrides the height the [compact] flag would pick. Text size
  /// still follows [compact] so a taller pill keeps its proportions.
  final double? height;

  @override
  State<RelayPillButton> createState() => _RelayPillButtonState();
}

class _RelayPillButtonState extends State<RelayPillButton> {
  static const LinearGradient _gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFFFE9A8), Color(0xFFFFC94A), Color(0xFFE79A1C)],
  );

  static const LinearGradient _plum = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFB88CFF), Color(0xFF8B4FE0), Color(0xFF5B2CA0)],
  );

  double _scale = 1;

  bool get _isGold => widget.tone == RelayButtonTone.gold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        child: Container(
          width: widget.width,
          height: widget.height ?? (widget.compact ? 46 : 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: _isGold ? _gold : _plum,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isGold ? const Color(0xFFFFF6E0) : const Color(0xFFFFD874),
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (_isGold
                        ? const Color(0xFF8A5300)
                        : const Color(0xFF2B1054))
                    .withValues(alpha: 0.55),
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 5),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: widget.compact ? 18 : 21,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0.4,
                  color: _isGold
                      ? const Color(0xFF4A2A00)
                      : const Color(0xFFFFF6E0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
