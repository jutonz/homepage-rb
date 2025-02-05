// just-debounce@1.1.0 downloaded from https://ga.jspm.io/npm:just-debounce@1.1.0/index.js

var e="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;var l={};l=debounce;function debounce(l,r,n,a){var o;var t;var u;return function debounced(){u=this||e;t=Array.prototype.slice.call(arguments);if(!o||!n&&!a){if(!n){clear();o=setTimeout(run,r);return o}o=setTimeout(clear,r);l.apply(u,t)}function run(){clear();l.apply(u,t)}function clear(){clearTimeout(o);o=null}}}var r=l;export default r;

