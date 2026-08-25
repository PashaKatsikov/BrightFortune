import 'package:flutter/services.dart';

/// Locks the app to landscape orientation. Used by every screen except the
/// loading screen, which supports both orientations.
Future<void> lockLandscape() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

Future<void> freeOrientation() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
