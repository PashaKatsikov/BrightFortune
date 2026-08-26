import 'package:flutter/material.dart';

import '../../app/relay_buttons.dart';
import '../../core/assets.dart';
import '../config/relay_config.dart';
import '../wire/alert_channel.dart';
import '../wire/beacon_keystore.dart';
import 'portal_stage.dart';

/// One-shot push opt-in promo shown before the portal (only when
/// `keystore.shouldInvitePermission` is true — first time, or after
/// the snooze window expired).
class PermissionStage extends StatefulWidget {
  const PermissionStage({
    super.key,
    required this.keystore,
    required this.alerts,
    required this.destinationUrl,
  });

  final BeaconKeystore keystore;
  final AlertChannel alerts;
  final String destinationUrl;

  @override
  State<PermissionStage> createState() => _PermissionStageState();
}

class _PermissionStageState extends State<PermissionStage> {
  Future<void> _accept() async {
    final bool granted = await widget.alerts.askPermission();
    if (!granted) {
      await widget.keystore.writePermissionSnoozeUntil(_snoozeTarget());
    }
    if (mounted) _forward();
  }

  Future<void> _skip() async {
    await widget.keystore.writePermissionSnoozeUntil(_snoozeTarget());
    if (mounted) _forward();
  }

  int _snoozeTarget() =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000 +
      RelayConfig.permissionSnoozeSeconds;

  void _forward() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PortalStage(
          url: widget.destinationUrl,
          keystore: widget.keystore,
          alerts: widget.alerts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final String bg = landscape
        ? Assets.notificationsHorizontal
        : Assets.notificationsVertical;
    // Accept and Skip are the same size on purpose: the opt-out must
    // never be the visually weaker option (pitfalls §12). Accept
    // leads by order alone — first in the column, left in the row.
    final double railWidth = landscape
        ? size.width * 0.35 * 0.9
        : (size.width * 0.72).clamp(220.0, 380.0);

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
                colors: <Color>[Colors.transparent, Color(0x88000000)],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height * (landscape ? 0.07 : 0.06),
            child: Center(
              child: landscape
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RelayPillButton(
                          label: 'Allow',
                          compact: true,
                          width: railWidth,
                          onTap: _accept,
                        ),
                        const SizedBox(width: 16),
                        RelayPillButton(
                          label: 'Skip',
                          tone: RelayButtonTone.plum,
                          compact: true,
                          width: railWidth,
                          onTap: _skip,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RelayPillButton(
                          label: 'Allow',
                          width: railWidth,
                          onTap: _accept,
                        ),
                        const SizedBox(height: 16),
                        RelayPillButton(
                          label: 'Skip',
                          tone: RelayButtonTone.plum,
                          width: railWidth,
                          onTap: _skip,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
