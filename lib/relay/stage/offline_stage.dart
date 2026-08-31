import 'package:flutter/material.dart';

import '../../app/relay_buttons.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';

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
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.skyBackground),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: landscape ? 48 : 32,
              vertical: landscape ? 20 : 36,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'NO INTERNET CONNECTION',
                            textAlign: TextAlign.center,
                            style: AppText.heading(
                              size: landscape ? 26 : 32,
                              color: AppColors.gold,
                            ),
                          ),
                          SizedBox(height: landscape ? 10 : 14),
                          Text(
                            'Check your connection and try again',
                            textAlign: TextAlign.center,
                            style: AppText.body_(
                              size: landscape ? 15 : 17,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: _spinning
                      ? const SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.gold,
                            ),
                          ),
                        )
                      : RelayPillButton(
                          label: 'Retry',
                          compact: landscape,
                          width: landscape
                              ? size.width * 0.35 * 1.1
                              : (size.width * 0.72).clamp(220.0, 380.0),
                          height: landscape ? 46 * 1.05 : null,
                          onTap: _retry,
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
