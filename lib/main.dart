import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'boot/boot_screen.dart';
import 'core/colors.dart';
import 'core/orientation_helper.dart';
import 'core/text_styles.dart';
import 'relay/config/relay_config.dart';
import 'relay/relay_coordinator.dart';
import 'relay/wire/alert_channel.dart';
import 'relay/wire/attribution_pulse.dart';
import 'relay/wire/beacon_keystore.dart';
import 'relay/wire/device_signature.dart';
import 'relay/wire/pulse_probe.dart';
import 'relay/wire/verdict_call.dart';

// ============================================================
// main.dart — bootstrap wiring
// ============================================================
// Order of operations (do NOT reorder without reading
// .cursor/START_HERE.md §3):
//   1. WidgetsFlutterBinding — required before any plugin call.
//   2. Firebase + AppCheck — wrapped in try/catch. A missing or
//      broken google-services.json must never block startup; the
//      coordinator falls back to the native game path.
//   3. Orientations + system chrome — every orientation is allowed
//      here so the boot screen can react to both; the game locks to
//      landscape once the boot screen hands off. The status bar and
//      the navigation bar stay hidden for the whole app life.
//   4. DeviceSignature.prime — builds the forged User-Agent shared
//      by the HTTP client and the WebView. MUST run before either
//      is constructed.
//   5. BeaconKeystore.prime — reads SharedPreferences into memory so
//      the route decision can read it synchronously.
//   6. Assemble the pipeline and mount the app.
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    );
  } catch (_) {}

  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  await enterImmersive();

  await DeviceSignature.prime();

  final BeaconKeystore keystore = BeaconKeystore();
  await keystore.prime();

  final PulseProbe probe = PulseProbe();
  final AttributionPulse pulse = AttributionPulse();
  final VerdictCall verdict = VerdictCall(keystore);
  final AlertChannel alerts = AlertChannel(keystore);

  final RelayCoordinator coordinator = RelayCoordinator(
    keystore: keystore,
    probe: probe,
    pulse: pulse,
    verdict: verdict,
    alerts: alerts,
  );

  runApp(BrightFortuneApp(
    coordinator: coordinator,
    keystore: keystore,
    alerts: alerts,
  ));
}

class BrightFortuneApp extends StatefulWidget {
  const BrightFortuneApp({
    super.key,
    required this.coordinator,
    required this.keystore,
    required this.alerts,
  });

  final RelayCoordinator coordinator;
  final BeaconKeystore keystore;
  final AlertChannel alerts;

  @override
  State<BrightFortuneApp> createState() => _BrightFortuneAppState();
}

class _BrightFortuneAppState extends State<BrightFortuneApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Sticky immersive lets a swipe reveal the bars briefly, and some
  /// OEMs restore them outright after a permission dialog or a
  /// keyboard session. Re-assert on every resume so no screen is ever
  /// left with a visible status or navigation bar.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) enterImmersive();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: RelayConfig.displayName,
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
      home: BootScreen(
        coordinator: widget.coordinator,
        keystore: widget.keystore,
        alerts: widget.alerts,
      ),
    );
  }
}
