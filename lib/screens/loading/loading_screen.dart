import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/orientation_helper.dart';
import '../../core/text_styles.dart';
import '../../services/audio_service.dart';
import '../../services/player_progress.dart';
import '../menu/main_menu_screen.dart';

/// Splash / loading screen. This is the only screen in the app that
/// supports both portrait and landscape orientation, swapping its artwork
/// to match. Once loading completes it locks the app to landscape and
/// transitions into the Main Menu.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final stopwatch = Stopwatch()..start();

    final allAssets = <String>[
      ...Assets.allSprites,
      ...Assets.allBackgrounds,
      Assets.gameName,
    ];

    for (var i = 0; i < allAssets.length; i++) {
      if (!mounted) return;
      await precacheImage(AssetImage(allAssets[i]), context);
      setState(() => _progress = (i + 1) / (allAssets.length + 2));
    }

    await AudioService.instance.init();
    if (mounted) setState(() => _progress = (allAssets.length + 1) / (allAssets.length + 2));

    await PlayerProgress.instance.load();
    if (mounted) setState(() => _progress = 1.0);

    // Keep the splash visible briefly so it never feels like a flash.
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 1400) {
      await Future.delayed(Duration(milliseconds: 1400 - elapsed));
    }

    await lockLandscape();
    // Give the platform a moment to settle the rotation before navigating.
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, anim, _) => FadeTransition(opacity: anim, child: const MainMenuScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120A2E),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final asset = orientation == Orientation.portrait
              ? Assets.loadingVertical
              : Assets.loadingHorizontal;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(asset, fit: BoxFit.cover),
              Positioned(
                left: 0,
                right: 0,
                bottom: orientation == Orientation.portrait ? 70 : 36,
                child: Center(
                  child: SizedBox(
                    width: orientation == Orientation.portrait ? 260 : 320,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 14,
                            backgroundColor: Colors.black.withValues(alpha: 0.45),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC94A)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading... ${(_progress * 100).clamp(0.0, 100).toStringAsFixed(0)}%',
                          style: AppText.body_(size: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
