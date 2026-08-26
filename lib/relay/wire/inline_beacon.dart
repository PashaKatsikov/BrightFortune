// ============================================================
// INLINE BEACON — cold-boot deep-link consumption
// ============================================================
// A cold-boot push tap on Android delivers the URL through the
// launch intent, which Firebase Messaging surfaces via
// `getInitialMessage()`. This class is the one-shot reader the
// coordinator calls before it routes, symmetric with the
// returning-launch code path.
//
// It deliberately reads the intent itself rather than waiting for
// `AlertChannel.boot()`: boot fetches the FCM token, which can
// stall for seconds on a cold network, and the tapped URL would
// then arrive after the routing decision had already been made —
// the notification would appear to "not work" on some launches.
//
// The URL is never written to storage. It belongs to the launch
// the tap started; every other launch resolves its destination
// from the config response (or the cached one).
// ============================================================

import '../config/relay_config.dart';
import 'alert_channel.dart';

class InlineBeacon {
  InlineBeacon._();

  /// Returns the URL carried by the push notification that launched
  /// the app, or `null` when this is an ordinary launch.
  static Future<String?> consume(AlertChannel alerts) => alerts.coldTapUrl(
        within: const Duration(seconds: RelayConfig.pushLaunchAwaitSeconds),
      );
}
