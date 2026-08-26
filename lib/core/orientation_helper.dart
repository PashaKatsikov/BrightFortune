import 'package:flutter/services.dart';

/// Locks the app to landscape orientation. Used by every screen except the
/// boot screen, which supports both orientations.
Future<void> lockLandscape() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

/// Hides the status bar and the navigation bar. Applies to every
/// surface — boot, shell screens, WebView and gameplay alike — so the
/// app never shows system chrome. Sticky mode means a swipe reveals
/// the bars translucently for a moment and then hides them again
/// without resizing the layout underneath.
Future<void> enterImmersive() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    systemNavigationBarColor: Color(0x00000000),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

/// Landscape lock plus the immersive chrome the gameplay screens
/// expect. Called once when the boot screen hands off to the menu.
Future<void> enterGameChrome() async {
  await enterImmersive();
  await lockLandscape();
}

Future<void> freeOrientation() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
