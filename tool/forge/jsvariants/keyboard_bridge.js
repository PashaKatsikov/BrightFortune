// Keyboard bridge call template — Bright Fortune variant.
//
// Not an install-time behaviour: the host evaluates this once per
// keyboard metric change, after substituting the placeholder.
//
//   %COVER% — share of the WebView's height the keyboard covers,
//             0 when it is closed
//
// A share rather than a length: the page may declare a scaled
// viewport, and converting dp to CSS pixels needs a factor neither
// side can measure reliably. Guarded with `&&` because the metric can
// change before the enhancer has been installed on a freshly loaded
// document.
window.__q4vKb && window.__q4vKb(%COVER%);
