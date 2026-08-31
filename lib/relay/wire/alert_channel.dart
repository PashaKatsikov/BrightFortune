import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'beacon_keystore.dart';
import 'relay_agent.dart';

// ============================================================
// ALERT CHANNEL — Firebase Messaging + local notifications
// ============================================================
// Cold-start push taps (app killed) are resolved by
// [coldTapUrl], which the coordinator calls BEFORE it routes —
// see `inline_beacon.dart`. Warm taps (background/foreground)
// deliver via [onIncomingUrl]. No push URL is ever persisted:
// they are valid for the launch they arrived on and nothing
// else.
//
// [FORGE] The Android notification channel id must match the
// `default_notification_channel_id` in AndroidManifest.xml. Rotate
// per project — a shared id creates an obvious cross-app cluster.
// ============================================================

// [FORGE] Rotate per project. Must match the AndroidManifest value.
const String kAlertChannelId = 'lantern_alerts';
// [FORGE] Rotate per project. User-visible in Android system settings.
const String kAlertChannelName = 'Updates and offers';
const String _smallIcon = '@drawable/ic_notification';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  // OS renders the notification; the tap is handled on resume/boot.
}

class AlertChannel {
  AlertChannel(this._keystore);

  final BeaconKeystore _keystore;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _messaging;
  String? _token;
  bool _ready = false;
  bool _launchIntentRead = false;

  /// Warm-tap URL delivery — the WebView should load this directly.
  void Function(String url)? onIncomingUrl;

  /// FCM rotated the token. Coordinator re-POSTs the verdict so the
  /// backend can target this device.
  void Function(String token)? onTokenChanged;

  String? get token => _token;

  Future<void> boot() async {
    if (_ready) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(_bgHandler);

      await _setupLocal();

      _token = await _messaging!.getToken();
      _messaging!.onTokenRefresh.listen((String t) {
        _token = t;
        onTokenChanged?.call(t);
      });

      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onWarmTap);

      _ready = true;
    } catch (_) {
      // Firebase not configured yet — push stays dormant.
    }
  }

  Future<void> _setupLocal() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings(_smallIcon);
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        final String? payload = r.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final Map<String, dynamic> data =
              jsonDecode(payload) as Map<String, dynamic>;
          final String? url = data['url'] as String?;
          if (url != null && url.isNotEmpty) onIncomingUrl?.call(url);
        } catch (_) {}
      },
    );

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _local.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          kAlertChannelId,
          kAlertChannelName,
          description: 'Updates and offers',
          importance: Importance.high,
        ),
      );
    }
  }

  /// System permission prompt. The invite stage treats an Allow tap
  /// as final on its own; this only records the OS result.
  Future<bool> askPermission() async {
    if (_messaging == null) return false;
    final NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final AuthorizationStatus status = settings.authorizationStatus;
    final bool granted = status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
    await _keystore.markPermissionGranted(granted);
    if (status == AuthorizationStatus.denied) {
      await _keystore.markPermissionBlockedByOs();
    }
    return granted;
  }

  void _onForeground(RemoteMessage message) async {
    final RemoteNotification? n = message.notification;
    if (n == null || !Platform.isAndroid) return;

    AndroidNotificationDetails? details;
    final String? imageUrl = n.android?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final Uint8List? bytes = await _fetchImage(imageUrl);
      if (bytes != null) {
        details = AndroidNotificationDetails(
          kAlertChannelId,
          kAlertChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: _smallIcon,
          styleInformation: BigPictureStyleInformation(
            ByteArrayAndroidBitmap(bytes),
            largeIcon:
                const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
        );
      }
    }

    details ??= const AndroidNotificationDetails(
      kAlertChannelId,
      kAlertChannelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: _smallIcon,
    );

    await _local.show(
      id: n.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(android: details),
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  /// URL of the push notification this launch was started from, or
  /// `null` for an ordinary launch.
  ///
  /// Reads the launch intent directly instead of waiting for [boot]:
  /// `getToken()` can take seconds on a cold, throttled network and
  /// the route decision must not race it. Firebase is already
  /// initialised in `main()`, so in practice this returns on the
  /// first microtask; the timeout only guards a wedged plugin.
  ///
  /// One-shot per launch, and de-duplicated across launches by
  /// message id — Android replays the original launch intent when the
  /// task is restored, which would otherwise re-open the same URL
  /// forever.
  Future<String?> coldTapUrl({required Duration within}) async {
    if (_launchIntentRead) return null;
    _launchIntentRead = true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final RemoteMessage? initial = await FirebaseMessaging.instance
          .getInitialMessage()
          .timeout(within);
      if (initial == null) return null;

      final String? url = initial.data['url'] as String?;
      if (url == null || url.isEmpty) return null;

      final String id = _tapId(initial, url);
      if (_keystore.pushAlreadyOpened(id)) return null;
      await _keystore.markPushOpened(id);
      return url;
    } catch (_) {
      return null;
    }
  }

  static String _tapId(RemoteMessage message, String url) {
    final String? messageId = message.messageId;
    if (messageId != null && messageId.isNotEmpty) return messageId;
    final int sent = message.sentTime?.millisecondsSinceEpoch ?? 0;
    return '$sent:${url.hashCode}';
  }

  void _onWarmTap(RemoteMessage message) {
    final String? url = message.data['url'] as String?;
    if (url != null && url.isNotEmpty) {
      onIncomingUrl?.call(url);
    }
  }

  Future<Uint8List?> _fetchImage(String url) async {
    try {
      final dynamic res = await relayAgent
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return res.bodyBytes as Uint8List;
    } catch (_) {}
    return null;
  }
}
