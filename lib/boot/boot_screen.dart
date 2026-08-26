import 'package:flutter/material.dart';

import '../core/assets.dart';
import '../core/colors.dart';
import '../core/orientation_helper.dart';
import '../core/text_styles.dart';
import '../relay/core/landing.dart';
import '../relay/relay_coordinator.dart';
import '../relay/stage/offline_stage.dart';
import '../relay/stage/permission_stage.dart';
import '../relay/stage/portal_stage.dart';
import '../relay/wire/alert_channel.dart';
import '../relay/wire/beacon_keystore.dart';
import '../screens/menu/main_menu_screen.dart';
import '../services/audio_service.dart';
import '../services/player_progress.dart';

// ============================================================
// BOOT SCREEN — the ONLY startup surface
// ============================================================
// Shows the loading art while [RelayCoordinator.decide] resolves,
// then destructures the sealed `Landing` and pushes exactly one
// route. This file holds no routing logic beyond `switch (landing)`.
//
// It is also the only place that supports both orientations: the
// game locks to landscape from here, the shell surfaces stay free.
//
// Progress budget: the decision owns 0 .. [_decisionShare]; warming
// the game art owns the remainder. The bar only ever moves forward
// and reaches 1.0 on the frame the next route is pushed.
// ============================================================

class BootScreen extends StatefulWidget {
  const BootScreen({
    super.key,
    required this.coordinator,
    required this.keystore,
    required this.alerts,
  });

  final RelayCoordinator coordinator;
  final BeaconKeystore keystore;
  final AlertChannel alerts;

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _dotsPeriod = Duration(milliseconds: 1200);
  static const Duration _minimumVisible = Duration(milliseconds: 1400);
  static const double _decisionShare = 0.6;

  double _progress = 0.03;
  bool _landed = false;
  late final AnimationController _dots;
  final Stopwatch _elapsed = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(vsync: this, duration: _dotsPeriod)..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _drive());
  }

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  Future<void> _drive() async {
    final Landing outcome = await widget.coordinator.decide(
      onProgress: (double value) => _lift(value * _decisionShare),
    );
    if (!mounted || _landed) return;
    _landed = true;

    final Widget next = switch (outcome) {
      OfflineLanding() => _prepareOffline(),
      GameLanding() => await _prepareGame(),
      PortalLanding(url: final String url) => _preparePortal(url),
    };

    // "No connection" is the one outcome that must not wait: running
    // the bar to 100% and only then admitting there is no network
    // reads as a failed load and makes users retry the wrong thing.
    // Every other outcome keeps the invariant that the bar reaches
    // 1.0 on the frame the next route is pushed.
    if (outcome is OfflineLanding) {
      _show(next, transition: Duration.zero);
      return;
    }

    _lift(1);
    await _holdSplash();
    _show(next);
  }

  void _show(
    Widget next, {
    Duration transition = const Duration(milliseconds: 450),
  }) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: transition,
        pageBuilder: (_, Animation<double> anim, _) =>
            FadeTransition(opacity: anim, child: next),
      ),
    );
  }

  /// Warms the game art, audio and saved progress, then hands the
  /// display over to landscape. Only runs on the native branch — a
  /// portal install must not pay for ~70 sprite decodes.
  Future<Widget> _prepareGame() async {
    final List<String> art = <String>[
      Assets.gameName,
      ...Assets.allBackgrounds,
      ...Assets.allSprites,
    ];
    for (int i = 0; i < art.length; i++) {
      if (!mounted) break;
      try {
        await precacheImage(AssetImage(art[i]), context);
      } catch (_) {
        // A single missing sprite must not strand the boot pipeline.
      }
      _lift(_decisionShare + (i + 1) / art.length * 0.35);
    }

    await AudioService.instance.init();
    await PlayerProgress.instance.load();

    await enterGameChrome();
    // Let the platform settle the rotation before the first frame.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const MainMenuScreen();
  }

  Widget _preparePortal(String url) {
    if (widget.keystore.shouldInvitePermission) {
      return PermissionStage(
        keystore: widget.keystore,
        alerts: widget.alerts,
        destinationUrl: url,
      );
    }
    return PortalStage(
      url: url,
      keystore: widget.keystore,
      alerts: widget.alerts,
    );
  }

  Widget _prepareOffline() {
    return OfflineStage(
      onRetryBuild: (_) => BootScreen(
        coordinator: widget.coordinator,
        keystore: widget.keystore,
        alerts: widget.alerts,
      ),
    );
  }

  void _lift(double value) {
    if (!mounted) return;
    final double next = value.clamp(0.0, 1.0);
    if (next <= _progress) return;
    setState(() => _progress = next);
  }

  Future<void> _holdSplash() async {
    final int remaining =
        _minimumVisible.inMilliseconds - _elapsed.elapsedMilliseconds;
    await Future<void>.delayed(
      Duration(milliseconds: remaining > 260 ? remaining : 260),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final String bg =
        landscape ? Assets.loadingHorizontal : Assets.loadingVertical;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(bg, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Color(0x99000000)],
              ),
            ),
          ),
          SafeArea(
            // Landscape: the notch / nav-bar insets arrive as left/right
            // padding and shove the progress rail off-centre. Immersive
            // chrome already hides the bars, so skip SafeArea entirely
            // in this orientation.
            left: !landscape,
            right: !landscape,
            top: !landscape,
            bottom: !landscape,
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, landscape ? 26 : 46),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _dots,
                    builder: (BuildContext context, _) {
                      final int tail = (_dots.value * 4).floor() % 4;
                      return Text(
                        'Loading${'.' * tail}',
                        style: AppText.heading(size: landscape ? 20 : 24),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ProgressTrack(value: _progress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        return Container(
          height: 18,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0x88120A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.panelBorder, width: 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              width: (c.maxWidth - 10) * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: AppColors.goldButton,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}
