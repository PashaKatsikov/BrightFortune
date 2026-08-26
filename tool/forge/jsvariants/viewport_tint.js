// Viewport tint — the project-specific behaviour that replaces the
// dropped autoplay enhancer, so the behaviour set has a different
// arity from any sibling.
//
// Purely cosmetic: paints the overscroll gutter in the app's own dark
// violet instead of the browser default white, and slims the
// scrollbar. Declared without !important so any colour the site sets
// on html/body still wins.
(function () {
  if (window.__q4vTint) { return; }
  var STYLE_ID = 'q4v-tint';
  if (document.getElementById(STYLE_ID)) { return; }
  var RULES = [
    'html{background-color:#0F0A24;}',
    '::-webkit-scrollbar{width:6px;height:6px;}',
    '::-webkit-scrollbar-track{background:transparent;}',
    '::-webkit-scrollbar-thumb{background:rgba(255,201,74,0.45);border-radius:3px;}'
  ];
  var tag = document.createElement('style');
  tag.id = STYLE_ID;
  tag.textContent = RULES.join('');
  (document.head || document.documentElement).appendChild(tag);
  window.__q4vTint = 1;
})();
