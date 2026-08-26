// Safe-area neutraliser — Bright Fortune variant.
//
// Shipped as a setProperty loop rather than a single <style> insert, and
// with the --sal alias dropped, so the body differs from every sibling
// while the semantics stay identical.
//
// HARD RULES (see .cursor/rules/webview_safe_area_injection.mdc):
//   - never zero padding-left / padding-right anywhere;
//   - never touch margins or padding on html / body / #app / #root;
//   - only padding-top / margin-top, only on known top-spacer classes;
//   - keep the CSS-variable overrides, they no-op on sites that do not
//     declare those variables;
//   - skip the whole patch while the keyboard is up, the compositor is
//     still resizing and the reset would visibly pop.
//
// The forge strips comment-only lines before encoding, so keep every
// comment on its own line and avoid block comments.
(function () {
  if (window.__q4vSafeArea) { return; }
  var VARS = [
    '--safe-area-inset-top',
    '--safe-area-inset-right',
    '--safe-area-inset-bottom',
    '--safe-area-inset-left',
    '--sat',
    '--sar',
    '--sab',
    '--safe-top',
    '--safe-bottom',
    '--safe-right'
  ];
  var HEADERS = [
    '.gameview-mobile-header',
    '.app-header',
    '.js-safe-top',
    '.mobile-topbar'
  ];
  var STYLE_ID = 'q4v-safe-top';
  function keyboardUp() {
    var vv = window.visualViewport;
    if (!vv) { return false; }
    return vv.height < window.innerHeight * 0.75;
  }
  function apply() {
    if (keyboardUp()) { return; }
    var root = document.documentElement;
    var i = 0;
    while (i < VARS.length) {
      root.style.setProperty(VARS[i], '0px', 'important');
      i = i + 1;
    }
    if (document.getElementById(STYLE_ID)) { return; }
    var tag = document.createElement('style');
    tag.id = STYLE_ID;
    tag.textContent = HEADERS.join(',') +
      '{padding-top:0 !important;margin-top:0 !important;}';
    (document.head || root).appendChild(tag);
  }
  apply();
  if (window.visualViewport) {
    window.visualViewport.addEventListener('resize', apply);
  }
  window.__q4vSafeArea = 1;
})();
