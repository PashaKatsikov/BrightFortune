import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around the AppsFlyer SDK. The game only needs one thing out
/// of attribution: whether an install is "organic" (found the app on its
/// own, e.g. store search/browse) or "non-organic" (arrived via a tracked
/// marketing source). AppsFlyer computes that for us in the post-install
/// conversion data payload (`af_status`); we cache it locally and also log
/// it back as an explicit AppsFlyer event so it's easy to segment on in the
/// dashboard without cross-referencing raw conversion data exports.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const String _devKey = 'L64QUBb5yCKzqrv5cSy6JS';

  bool? _isOrganic;

  /// Null until the first conversion data callback arrives after install.
  bool? get isOrganicUser => _isOrganic;

  Future<void> init() async {
    try {
      final options = AppsFlyerOptions(
        afDevKey: _devKey,
        appId: '', // iOS-only field; this build targets Android only.
        showDebug: kDebugMode,
      );
      final sdk = AppsflyerSdk(options);

      sdk.onInstallConversionData((res) {
        final payload = res is Map ? res['payload'] : null;
        final status = payload is Map ? payload['af_status'] as String? : null;
        if (status == null) return;
        _isOrganic = status.toLowerCase() == 'organic';
        sdk.logEvent('user_attribution_status', {
          'af_status': status,
          'is_organic': _isOrganic,
        });
      });

      await sdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: false,
        registerOnDeepLinkingCallback: false,
      );
    } catch (e, st) {
      // Attribution is best-effort - never let SDK/network issues affect
      // startup or gameplay.
      debugPrint('AnalyticsService: AppsFlyer init failed: $e\n$st');
    }
  }
}
