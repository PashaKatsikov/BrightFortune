import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/colors.dart';
import 'core/text_styles.dart';
import 'screens/loading/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow every orientation initially so the loading screen can react to
  // both portrait and landscape as required. Gameplay screens lock to
  // landscape themselves once the loading screen hands off.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const BrightFortuneApp());
}

class BrightFortuneApp extends StatelessWidget {
  const BrightFortuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bright Fortune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppText.body,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}
