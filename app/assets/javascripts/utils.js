"use strict";

// Returns the most recent style for a named css rule
function getStyleRules(prefix, names) {
  var result = {};
  for (var i = document.styleSheets.length; --i >= 0; ) {
    var ix, sheet = document.styleSheets[i];
    if (sheet.cssRules !== null) {
      for (ix = sheet.cssRules.length; --ix >= 0;) {
        var selector = sheet.cssRules[ix].selectorText;
        if (selector !== undefined && selector.startsWith(prefix)) {
          var name = selector.replace(prefix, '');
          if (names.indexOf(name) > -1)
            result[name] = sheet.cssRules[ix].style;
        }
      }
    }
  }
  return result;
}
