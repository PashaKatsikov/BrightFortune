import 'package:flutter/material.dart';

import '../../app/relay_buttons.dart';
import '../../core/assets.dart';

/// Shown whenever the relay pipeline concludes "no network".
///
/// Retry rebuilds the caller-supplied route through
/// `pushReplacement`. The pipeline is idempotent by design — the
/// coordinator's in-flight cache clears on completion, so Retry
/// runs the full boot flow fresh (attribution → probe → verdict).
class OfflineStage extends StatefulWidget {
  const OfflineStage({super.key, required this.onRetryBuild});

  final WidgetBuilder onRetryBuild;

  @override
  State<OfflineStage> createState() => _OfflineStageState();
}

class _OfflineStageState extends State<OfflineStage> {
  bool _spinning = false;

  Future<void> _retry() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    await Future<void>.delayed(const Duration(milliseconds: 620));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: widget.onRetryBuild),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final String bg =
        landscape ? Assets.noWifiHorizontal : Assets.noWifiVertical;
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0A24),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(bg,
              fit: BoxFit.cover, width: size.width, height: size.height),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Color(0x99000000)],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height * (landscape ? 0.1 : 0.07),
            child: Center(
              child: _spinning
                  ? const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFC94A)),
                      ),
                    )
                  : RelayPillButton(
                      label: 'Retry',
                      compact: landscape,
                      // Capped so the pill never goes full-bleed on
                      // tablets or in landscape — pitfalls §18.
                      width: landscape
                          ? size.width * 0.35 * 1.1
                          : (size.width * 0.72).clamp(220.0, 380.0),
                      height: landscape ? 46 * 1.05 : null,
                      onTap: _retry,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
