// Keyboard reveal — Bright Fortune variant.
//
// The reveal is BLINK'S JOB, and this script exists only for the
// cases where Blink declines it. That is the whole design, and it is
// worth spelling out why, because the obvious alternative — lifting
// the field ourselves — cannot be made stable.
//
// Two things can move the page when the keyboard opens:
//
//   1. Android resizing the window. Suppressed for API >= 30 by
//      SOFT_INPUT_ADJUST_NOTHING in MainActivity, because resizing
//      reflows the document and a fixed dialog sized in vh/% shrinks
//      with it — the registration modal collapsing into a strip.
//   2. Blink. `adjustNothing` does not hide the keyboard from the
//      renderer: the IME inset still reaches the WebView, so with the
//      default `interactive-widget=resizes-visual` Chromium shrinks
//      the VISUAL viewport only and smooth-pans it to keep the caret
//      in view. The LAYOUT viewport is untouched, so nothing reflows
//      and the dialog keeps its size, while the pan carries fixed
//      elements up with everything else.
//
// So (1) is the bug and (2) is already the behaviour we want: one
// native, composited, correctly-timed motion that puts the focused
// field above the keyboard exactly as Chrome does on any website.
//
// Adding our own lift on top of it is what produced every glitch
// reported against this file. Blink's pan is invisible to
// `getBoundingClientRect`, which stays in layout coordinates, so our
// lift double-counted it; the pan moves `offsetTop` and `height`
// across several frames, so measuring mid-pan overshot and had to be
// walked back; and anything we leave on the element between sessions
// (`will-change` creating a containing block, a transition making
// `getComputedStyle` return animating values) makes the first reveal
// exact and every later one slightly off. None of that is fixable
// while two parties animate the same pixels.
//
// Therefore, whenever Blink has the field in view, this script does
// NOTHING — not a single DOM write, so there is no state to leak into
// the next keyboard session and no second animation to collide with.
//
// It steps in for two cases only:
//
//   - the host reports a keyboard that Blink is visibly ignoring: a
//     page that declares `interactive-widget=overlays-content` itself,
//     or a WebView too old for the visual viewport to react;
//   - Blink shrank the viewport but left the field genuinely below it.
//
// Both are measured only after the viewport falls quiet, so nothing
// else is in motion, and the correction is one instant, un-animated
// translate3d on the field's nearest `position: fixed` ancestor. It
// lands in the right place first time. The existing transform is
// composed onto, never overwritten — centred dialogs carry
// `translate(-50%, -50%)` from a stylesheet and an inline transform of
// our own would drop the centring.
//
// Note the missing comfort margin in the second case: Blink's idea of
// the gap above the keyboard is not ours, and insisting on ours would
// add a visible second nudge to a placement that was already right.
//
// The host reports what SHARE of the viewport the keyboard covers,
// dimensionless because a page may declare a scaled viewport and the
// dp-to-CSS-pixel factor is not measurable from either side. Reports
// arrive throughout the IME animation; we act on the last one, once
// the viewport has fallen quiet.
//
// window.__q4vKb(share) is the entry point the host calls; see
// tool/forge/jsvariants/keyboard_bridge.js.
(function () {
  if (window.__q4vKeyboard) { return; }
  var FIELDS = 'input, textarea, select, [contenteditable="true"]';
  var QUIET = 140;
  var CAP = 0.85;
  var SLACK = 4;
  var share = 0;
  var timer = 0;
  var host = null;
  var inlineBefore = '';
  var baseTransform = '';
  var applied = 0;
  function blinkOwns() {
    var vv = window.visualViewport;
    return !!vv && vv.height > 0 && window.innerHeight - vv.height > 1;
  }
  function gap() {
    var v = Math.round(window.innerHeight * 0.02);
    if (v < 8) { return 8; }
    if (v > 28) { return 28; }
    return v;
  }
  function field() {
    var node = document.activeElement;
    if (!node || typeof node.matches !== 'function') { return null; }
    return node.matches(FIELDS) ? node : null;
  }
  function pinned(node) {
    var el = node.parentElement;
    while (el && el !== document.body) {
      if (window.getComputedStyle(el).position === 'fixed') { return el; }
      el = el.parentElement;
    }
    return null;
  }
  function drop() {
    applied = 0;
    if (!host) { return; }
    host.style.transform = inlineBefore;
    host = null;
    inlineBefore = '';
    baseTransform = '';
  }
  function raise(el, dy) {
    if (host !== el) {
      drop();
      host = el;
      inlineBefore = el.style.transform;
      var computed = window.getComputedStyle(el).transform;
      baseTransform = computed === 'none' ? '' : computed;
    }
    applied = dy;
    var head = baseTransform === '' ? '' : baseTransform + ' ';
    el.style.transform = head + 'translate3d(0px, ' + (-dy) + 'px, 0px)';
  }
  function visibleTop() {
    return blinkOwns() ? window.visualViewport.offsetTop : 0;
  }
  function visibleBottom() {
    if (blinkOwns()) {
      var vv = window.visualViewport;
      return vv.offsetTop + vv.height;
    }
    var cover = share > CAP ? CAP : share;
    return window.innerHeight * (1 - cover);
  }
  function fix() {
    var node = field();
    if (!node || share <= 0) { drop(); return; }
    var anchor = pinned(node);
    var raised = (host && host === anchor) ? applied : 0;
    var box = node.getBoundingClientRect();
    var margin = blinkOwns() ? 0 : gap();
    var hidden = box.bottom + raised - (visibleBottom() - margin);
    var room = box.top + raised - (visibleTop() + margin);
    var dy = hidden < room ? hidden : room;
    if (dy < SLACK) { dy = 0; }
    if (!anchor) {
      drop();
      if (dy > 0) { window.scrollBy(0, dy); }
      return;
    }
    if (dy === 0 && !host) { return; }
    raise(anchor, dy);
  }
  function later() {
    window.clearTimeout(timer);
    timer = window.setTimeout(function () {
      timer = 0;
      fix();
    }, QUIET);
  }
  window.__q4vKb = function (cover) {
    share = cover > 0 ? cover : 0;
    if (share <= 0) {
      window.clearTimeout(timer);
      timer = 0;
      drop();
      return;
    }
    later();
  };
  document.addEventListener('focusin', later, true);
  if (window.visualViewport) {
    window.visualViewport.addEventListener('resize', later);
    window.visualViewport.addEventListener('scroll', later);
  }
  window.__q4vKeyboard = 1;
})();
