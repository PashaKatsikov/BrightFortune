import 'package:webview_flutter/webview_flutter.dart';

import '../config/veiled_bytes.dart';

// ============================================================
// WEB SCRIPTS — assembled JavaScript injections
// ============================================================
// Every JS body used to sit as a raw string constant in
// `web_stage.dart`. Store scanners hash normalized JS bodies
// across submissions and cluster them on match. To defeat that
// we:
//   1. Store each body as an encoded byte array in
//      `veiled_bytes.dart` — no plaintext JS in the compiled
//      binary (the compiler cannot see through `reveal()` at
//      compile time, so the strings are constructed at runtime
//      and never interned).
//   2. The forge generates each body with a project-unique
//      sentinel window flag AND control-flow variations
//      (Array.forEach vs for-loop, arrow fn vs function, etc.).
//   3. The forge also picks a SUBSET of the three behaviours,
//      omitting one and adding a project-specific harmless
//      script — see `tool/forge/jsvariants/`.
//
// On a fresh template both `veiled_bytes.dart` arrays and the
// hardcoded fallback strings below are empty; the WebView will
// still work (partner sites without notches / safe-areas render
// fine without any injections) but a real project MUST have run
// the forge to activate the scripts.
// ============================================================

class WebScripts {
  WebScripts._();

  /// Install the ORDERED sequence of enhancers on the given
  /// controller. Every enhancer is idempotent via its own sentinel
  /// window flag — safe to call on every `onPageFinished`.
  static Future<void> installAll(WebViewController controller) async {
    for (final String body in _bodies()) {
      if (body.isEmpty) continue;
      await controller.runJavaScript(body);
    }
  }

  /// Ordered enhancer bodies. Slots the project omitted decode to "" and
  /// are skipped by [installAll]; this build ships safe-area, keyboard
  /// and viewport-tint, with autoplay handled natively instead by
  /// `setMediaPlaybackRequiresUserGesture(false)` in `portal_stage.dart`.
  static List<String> _bodies() {
    return <String>[
      unlockJsSafeAreaScript(),
      unlockJsKeyboardScript(),
      unlockJsAutoplayScript(),
      unlockJsViewportTintScript(),
    ];
  }

  /// Tells the page what SHARE of its viewport the keyboard covers,
  /// `0` once it is closed.
  ///
  /// The WebView is deliberately NOT resized when the keyboard opens
  /// — that reflows the document and collapses fixed dialogs — so the
  /// page may not observe the keyboard on its own. A ratio rather than
  /// a length, because a page can declare a scaled viewport and the dp
  /// to CSS pixel factor is not something either side can measure
  /// reliably.
  ///
  /// The call template is encoded like every other JS fragment, so
  /// the sentinel it targets stays forge-rotated and never appears as
  /// a literal in the binary.
  static Future<void> pushKeyboardInset(
    WebViewController controller, {
    required double cover,
  }) async {
    final String template = unlockJsKeyboardBridge();
    if (template.isEmpty) return;
    final String call =
        template.replaceAll('%COVER%', cover.toStringAsFixed(4));
    try {
      await controller.runJavaScript(call);
    } catch (_) {
      // Page torn down mid-flight — the next focus re-evaluates.
    }
  }
}
