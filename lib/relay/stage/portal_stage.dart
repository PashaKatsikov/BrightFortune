import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../config/relay_config.dart';
import '../wire/alert_channel.dart';
import '../wire/beacon_keystore.dart';
import '../wire/device_signature.dart';
import '../wire/pulse_probe.dart';
import '../wire/web_scripts.dart';
import 'offline_stage.dart';

// ============================================================
// PORTAL STAGE — the WebView shell (gray content)
// ============================================================
// Hosts the destination URL with:
//   • forged device UA (identical to the HTTP client's UA)
//   • both orientations, immersive system UI
//   • external-scheme hand-off (tel:, mailto:, intent://)
//   • redirect-loop recovery (main-frame -1007 / -9 with a
//     bounded retry)
//   • keyboard geometry forwarded to the page (the WebView is
//     never resized — see the padding note in `build`)
//   • live connectivity guard (debounced)
//   • warm push URL delivery via [AlertChannel.onIncomingUrl]
//   • native file chooser via MethodChannel (no file_picker dep)
//   • JS behaviours composed by `WebScripts.installAll`
//
// NOTE: The client never inspects or classifies the pages it
// loads — no page-type matching, no step tracking. Anything of
// that sort belongs server side; this is a dumb shell.
// ============================================================

class PortalStage extends StatefulWidget {
  const PortalStage({
    super.key,
    required this.url,
    required this.keystore,
    required this.alerts,
  });

  final String url;
  final BeaconKeystore keystore;
  final AlertChannel alerts;

  @override
  State<PortalStage> createState() => _PortalStageState();
}

class _PortalStageState extends State<PortalStage>
    with WidgetsBindingObserver {
  late final WebViewController _web;
  bool _spinner = true;
  bool _offlineShown = false;
  String? _lastMainFrame;
  double _keyboardInset = 0;
  EdgeInsets _restInsets = EdgeInsets.zero;
  Size? _insetBasis;
  int _retryCounter = 0;

  /// From API 30 the IME inset arrives through `WindowInsets.Type.ime()`
  /// whatever the soft-input mode, so `MainActivity` puts the window in
  /// ADJUST_NOTHING and we drive the keyboard reveal ourselves. Below
  /// that the window still resizes and Chromium scrolls the focused
  /// field on its own — pushing our own offset there would move the
  /// content twice.
  static bool get _ownsKeyboard => DeviceSignature.androidSdk >= 30;
  Timer? _dropDebounce;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  // [FORGE] Rotate the MethodChannel name per project. Keep in
  // sync with MainActivity.kt → `channelName`.
  static const MethodChannel _uploadChannel = MethodChannel('lantern/chooser');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _enterImmersive();
    _buildController();

    widget.alerts.onIncomingUrl = (String url) {
      if (mounted) _web.loadRequest(Uri.parse(url));
    };

    // Debounce connectivity drops — a VPN reconnect or a brief cell
    // switch produces a burst of `none` events that must not fire
    // the offline stage. Only sustained drops route out.
    _connSub = PulseProbe().statusStream.listen((List<ConnectivityResult> r) {
      final bool allNone =
          r.isNotEmpty && r.every((ConnectivityResult e) => e == ConnectivityResult.none);
      if (!allNone) {
        _dropDebounce?.cancel();
        return;
      }
      _dropDebounce?.cancel();
      _dropDebounce = Timer(
        Duration(milliseconds: RelayConfig.reachDropDebounceMs),
        _showOffline,
      );
    });
  }

  void _enterImmersive() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _enterImmersive();
  }

  /// Forwards the keyboard geometry to the page.
  ///
  /// Read straight off the [FlutterView] rather than through
  /// MediaQuery so it lands on the same frame Android reports the
  /// inset — routing it through a rebuild adds a frame of latency,
  /// which is visible as the content lagging behind the keyboard.
  ///
  /// `viewInsets.bottom` is the IME height on its own from API 30,
  /// which is the only path this runs on.
  @override
  void didChangeMetrics() {
    if (!mounted || !_ownsKeyboard) return;
    final double ratio = View.of(context).devicePixelRatio;
    if (ratio <= 0) return;
    final double inset = View.of(context).viewInsets.bottom / ratio;
    if ((inset - _keyboardInset).abs() < 1) return;
    _keyboardInset = inset;
    _pushKeyboardInset();
  }

  /// Insets the WebView is padded by: the smallest `viewPadding` seen
  /// for the current screen geometry.
  ///
  /// `viewPadding` is not stable. Android reveals the navigation bar
  /// when the keyboard opens and hides it again when the keyboard
  /// closes, and each transition arrives as a padding change — a side
  /// inset in landscape, a bottom strip in portrait, the status bar at
  /// the top. Following it resizes the WebView mid-typing, and the
  /// hide is just as visible as the show: a brief safe area that snaps
  /// back.
  ///
  /// A running minimum solves it without guessing when the bars are
  /// up: system bars can only ever ADD padding, so the minimum
  /// converges on the bar-less geometry — in practice the display
  /// cutout alone — and never grows again. It is reset when the screen
  /// size changes, since a rotation moves the cutout to another edge.
  EdgeInsets _chromeInsets(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final EdgeInsets view = MediaQuery.viewPaddingOf(context);
    final EdgeInsets sample = EdgeInsets.only(
      left: view.left,
      right: view.right,
      top: view.top,
    );
    if (_insetBasis != size) {
      _insetBasis = size;
      _restInsets = sample;
      return _restInsets;
    }
    _restInsets = EdgeInsets.only(
      left: math.min(_restInsets.left, sample.left),
      right: math.min(_restInsets.right, sample.right),
      top: math.min(_restInsets.top, sample.top),
    );
    return _restInsets;
  }

  void _pushKeyboardInset() {
    if (!mounted) return;
    final ui.FlutterView view = View.of(context);
    final double ratio = view.devicePixelRatio;
    if (ratio <= 0) return;
    // Physical pixels on both sides of the division, so the result is
    // a plain share of the WebView's height with no dp-to-CSS-pixel
    // conversion to get wrong. The WebView's own height is the window
    // minus the padding it is laid out with — only the top carries an
    // inset, the bars float over the rest.
    final double height = view.physicalSize.height - _restInsets.top * ratio;
    if (height <= 0) return;
    WebScripts.pushKeyboardInset(
      _web,
      cover: (_keyboardInset * ratio / height).clamp(0.0, 1.0),
    );
  }

  void _buildController() {
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(DeviceSignature.userAgent)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _spinner = true);
        },
        onPageFinished: (_) async {
          if (mounted) setState(() => _spinner = false);
          _retryCounter = 0;
          await WebScripts.installAll(_web);
          // A document loaded while the keyboard is up starts with a
          // fresh enhancer that knows nothing about it.
          if (_keyboardInset > 0) _pushKeyboardInset();
        },
        onWebResourceError: _onError,
        onNavigationRequest: _onNavigate,
      ));

    _configureAndroid();
    _web.loadRequest(Uri.parse(widget.url));
  }

  void _onError(WebResourceError err) {
    if (err.isForMainFrame != true) return;

    final String desc = err.description.toLowerCase();
    final bool isLoop = desc.contains('too_many_redirects') ||
        desc.contains('too many redirects') ||
        err.errorCode == -1007 ||
        err.errorCode == -9;

    if (isLoop &&
        _lastMainFrame != null &&
        _retryCounter < RelayConfig.redirectLoopRetries) {
      _retryCounter++;
      _web.loadRequest(Uri.parse(_lastMainFrame!));
      return;
    }

    // Cover the WebView's native error page immediately so the
    // Android chrome robot never leaks visually.
    if (mounted) setState(() => _spinner = true);

    final bool isConnectivity = desc.contains('name_not_resolved') ||
        desc.contains('address_unreachable') ||
        desc.contains('internet_disconnected') ||
        desc.contains('network_changed') ||
        err.errorCode == -105 ||
        err.errorCode == -106 ||
        err.errorCode == -21 ||
        err.errorCode == -2 ||
        err.errorCode == -6;

    if (isConnectivity) {
      _showOffline();
    } else {
      _guardOffline();
    }
  }

  NavigationDecision _onNavigate(NavigationRequest req) {
    final Uri? uri = Uri.tryParse(req.url);
    if (uri == null) return NavigationDecision.prevent;
    const Set<String> inApp = <String>{
      'http',
      'https',
      'about',
      'data',
      'blob',
    };
    if (inApp.contains(uri.scheme)) {
      if (req.isMainFrame) _lastMainFrame = req.url;
      return NavigationDecision.navigate;
    }
    _openExternally(uri);
    return NavigationDecision.prevent;
  }

  void _configureAndroid() {
    if (!Platform.isAndroid) return;
    if (_web.platform is! AndroidWebViewController) return;
    final AndroidWebViewController controller =
        _web.platform as AndroidWebViewController;

    controller.setMediaPlaybackRequiresUserGesture(false);
    controller.setOnPlatformPermissionRequest(
      (PlatformWebViewPermissionRequest r) => r.grant(),
    );
    controller.setOnShowFileSelector(_pickFiles);

    final AndroidWebViewCookieManager cookies = AndroidWebViewCookieManager(
      AndroidWebViewCookieManagerCreationParams
          .fromPlatformWebViewCookieManagerCreationParams(
        const PlatformWebViewCookieManagerCreationParams(),
      ),
    );
    cookies.setAcceptThirdPartyCookies(controller, true);
  }

  Future<List<String>> _pickFiles(FileSelectorParams params) async {
    try {
      final List<Object?>? picked = await _uploadChannel
          .invokeMethod<List<Object?>>('pick', <String, Object>{
        'multiple': params.mode == FileSelectorMode.openMultiple,
        'mimeTypes': params.acceptTypes
            .where((String t) => t.trim().isNotEmpty)
            .toList(),
      });
      if (picked == null) return const <String>[];
      return picked.whereType<String>().toList();
    } catch (_) {
      return const <String>[];
    }
  }

  Future<void> _openExternally(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _guardOffline() async {
    if (_offlineShown) return;
    final bool online = await PulseProbe().canDialOut();
    if (online) return;
    _showOffline();
  }

  void _showOffline() {
    if (_offlineShown || !mounted) return;
    _offlineShown = true;
    final String current = _lastMainFrame ?? widget.url;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OfflineStage(
          onRetryBuild: (_) => PortalStage(
            url: current,
            keystore: widget.keystore,
            alerts: widget.alerts,
          ),
        ),
      ),
    );
  }

  Future<void> _stepBack() async {
    if (await _web.canGoBack()) await _web.goBack();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dropDebounce?.cancel();
    _connSub?.cancel();
    widget.alerts.onIncomingUrl = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (!didPop) await _stepBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Padding(
              // Immune to the system bars and carrying no keyboard
              // inset of its own, so the WebView keeps one size for
              // the whole session. Resizing it would reflow the
              // document, collapse fixed dialogs (a login modal turns
              // into a strip) and make the motion stutter. The page is
              // told the keyboard height through
              // `WebScripts.pushKeyboardInset` and lifts the focused
              // field with a composited transform instead.
              padding: _chromeInsets(context),
              child: WebViewWidget(controller: _web),
            ),
            // Covers the WebView in BOTH orientations — the native
            // error page must never be visible while we decide where
            // to route (pitfalls §4).
            if (_spinner)
              const ColoredBox(
                color: Color(0xE60F0A24),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFFC94A)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
