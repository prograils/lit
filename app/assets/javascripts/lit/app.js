(function() {
  'use strict';

  var globals = typeof global === 'undefined' ? self : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = {}.hasOwnProperty;

  var expRe = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (expRe.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var hot = hmr && hmr.createHot(name);
    var module = {id: name, exports: {}, hot: hot};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var expandAlias = function(name) {
    return aliases[name] ? expandAlias(aliases[name]) : name;
  };

  var _resolve = function(name, dep) {
    return expandAlias(expand(dirname(name), dep));
  };

  var require = function(name, loaderPath) {
    if (loaderPath == null) loaderPath = '/';
    var path = expandAlias(name);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    throw new Error("Cannot find module '" + name + "' from '" + loaderPath + "'");
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  var extRe = /\.[^.\/]+$/;
  var indexRe = /\/index(\.[^\/]+)?$/;
  var addExtensions = function(bundle) {
    if (extRe.test(bundle)) {
      var alias = bundle.replace(extRe, '');
      if (!has.call(aliases, alias) || aliases[alias].replace(extRe, '') === alias + '/index') {
        aliases[alias] = bundle;
      }
    }

    if (indexRe.test(bundle)) {
      var iAlias = bundle.replace(indexRe, '');
      if (!has.call(aliases, iAlias)) {
        aliases[iAlias] = bundle;
      }
    }
  };

  require.register = require.define = function(bundle, fn) {
    if (bundle && typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          require.register(key, bundle[key]);
        }
      }
    } else {
      modules[bundle] = fn;
      delete cache[bundle];
      addExtensions(bundle);
    }
  };

  require.list = function() {
    var list = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        list.push(item);
      }
    }
    return list;
  };

  var hmr = globals._hmr && new globals._hmr(_resolve, require, modules, cache);
  require._cache = cache;
  require.hmr = hmr && hmr.wrap;
  require.brunch = true;
  globals.require = require;
})();

(function() {
var global = typeof window === 'undefined' ? this : window;
var __makeRelativeRequire = function(require, mappings, pref) {
  var none = {};
  var tryReq = function(name, pref) {
    var val;
    try {
      val = require(pref + '/node_modules/' + name);
      return val;
    } catch (e) {
      if (e.toString().indexOf('Cannot find module') === -1) {
        throw e;
      }

      if (pref.indexOf('node_modules') !== -1) {
        var s = pref.split('/');
        var i = s.lastIndexOf('node_modules');
        var newPref = s.slice(0, i).join('/');
        return tryReq(name, newPref);
      }
    }
    return none;
  };
  return function(name) {
    if (name in mappings) name = mappings[name];
    if (!name) return;
    if (name[0] !== '.' && pref) {
      var val = tryReq(name, pref);
      if (val !== none) return val;
    }
    return require(name);
  }
};
require.register("src/lit/backend/localizations.js", function(exports, require, module) {
'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

var _pell = require('pell');

var _pell2 = _interopRequireDefault(_pell);

var _utils = require('../utils');

var _utils2 = _interopRequireDefault(_utils);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var edited_rows = {};

document.addEventListener('DOMContentLoaded', function () {
  var localizationRows = document.querySelectorAll('td.localization_row[data-editing="0"]');

  localizationRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      var tdElem = e.currentTarget;
      if (!parseInt(tdElem.dataset.editing)) {
        edited_rows[tdElem.dataset.id] = tdElem.innerHTML;
        var rowElem = document.querySelector('td.localization_row[data-id="' + tdElem.dataset.id + '"]');
        if (!parseInt(tdElem.dataset.editing) && tdElem.dataset.edit) {
          tdElem.dataset.editing = '1';
          fetch(tdElem.dataset.edit).then(function (resp) {
            return resp.json();
          }).then(function (_ref) {
            var html = _ref.html,
                isHtmlKey = _ref.isHtmlKey;

            rowElem.dataset.editing = 1;
            rowElem.innerHTML = html;
            rowElem.querySelector('textarea, input').focus();
            if (isHtmlKey) {
              rowElem.querySelector('.wysiwyg_switch').click();
            }

            rowElem.querySelector('form').addEventListener('submit', function (e) {
              var url = e.target.action;
              fetch(url, {
                method: 'PATCH',
                headers: {
                  'X-CSRF-Token': Rails.csrfToken(),
                  'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                  localization: {
                    translated_value: rowElem.querySelector('textarea').value
                  }
                })
              }).then(function (resp) {
                return resp.json();
              }).then(function (_ref2) {
                var localizationId = _ref2.localizationId,
                    html = _ref2.html;

                delete rowElem.dataset.editing;
                rowElem.innerHTML = html;
                rowElem.parentElement.querySelector('.show_prev_versions').classList.remove('hidden');
                document.querySelector('a.change_completed_' + localizationId + ' input[type="checkbox"]').checked = true;
              });
              e.preventDefault();
            });

            var handleCloudTranslationLinkClick = function handleCloudTranslationLinkClick(e) {
              e.preventDefault();
              var url = e.target.href;
              fetch(url).then(function (resp) {
                return resp.json();
              }).then(function (_ref3) {
                var translatedText = _ref3.translatedText;

                if (typeof translatedText === 'string') {
                  var textareaElem = rowElem.querySelector('textarea');
                  textareaElem.value = translatedText;
                  if (isHtmlKey) {
                    var pellElement = rowElem.querySelector('.pell');
                    pellElement.content.innerHTML = translatedText;
                  }
                } else if ((typeof translatedText === 'undefined' ? 'undefined' : _typeof(translatedText)) === 'object') {
                  var inputElems = rowElem.querySelectorAll('input[type="text"]');
                  inputElems.forEach(function (inputElem, i) {
                    return inputElem.value = translatedText[i];
                  });
                }
              });
            };

            rowElem.querySelectorAll('.js-cloud-translation-link').forEach(function (link) {
              link.addEventListener('click', handleCloudTranslationLinkClick);
            });
          });
        }
      }
    });
  });

  var allLocalizationRows = document.querySelectorAll('td.localization_row');

  allLocalizationRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (e.target.matches('form button.cancel')) {
        if (e.target.localName === 'button') {
          var refElem = _utils2.default.closest(e.target, 'td.localization_row');
          refElem.dataset.editing = '0';
          refElem.innerHTML = edited_rows[refElem.dataset.id];
          e.preventDefault();
          return false;
        }
      }
    });
  });

  var localizationVersionsRows = document.querySelectorAll('tr.localization_versions_row');

  localizationVersionsRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (e.target.matches('.close_versions')) {
        var refElem = _utils2.default.closest(e.target, 'tr.localization_versions_row');
        refElem.classList.add('hidden');
        refElem.querySelectorAll('td').forEach(function (td) {
          return td.innerHTML = '';
        });
      }
    });
  });

  var localizationKeyRows = document.querySelectorAll('tr.localization_key_row');

  localizationKeyRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (e.target.matches('input.wysiwyg_switch')) {
        var refElem = _utils2.default.closest(e.target, 'form');
        var textarea = refElem.querySelector('textarea');
        var pellElement = refElem.querySelector('.pell');

        if (e.target.checked) {
          if (!pellElement.content) {
            _pell2.default.init({
              element: pellElement,
              onChange: function onChange(html) {
                return textarea.value = html;
              }
            });
          }

          pellElement.content.innerHTML = textarea.value;
          textarea.style.display = 'none';
          pellElement.style.display = '';
        } else {
          textarea.style.display = '';
          pellElement.style.display = 'none';
        }
      }

      if (e.target.matches('.request_info_link')) {
        var _refElem = _utils2.default.closest(e.target, 'tr.localization_key_row');
        requestInfoRow = _refElem.querySelector('.request_info_row');
        if (requestInfoRow.classList.contains('hidden')) {
          requestInfoRow.classList.remove('hidden');
        } else {
          requestInfoRow.classList.add('hidden');
        }
      }
    });
  });
});
});

;require.register("src/lit/backend/sources.js", function(exports, require, module) {
'use strict';

document.addEventListener('DOMContentLoaded', function () {
  var loadingElement = document.querySelector('.loading');

  var updateFunc = function updateFunc() {
    var sourceIdElement = document.querySelector('#source_id');
    if (!sourceIdElement) {
      return;
    }

    var sourceId = sourceIdElement.value;

    fetch('/lit/sources/' + sourceId + '/sync_complete').then(function (resp) {
      if (resp.ok) {
        return resp.json();
      } else {
        return Promise.reject({ status: resp.status });
      }
    }).then(function (json) {
      if (json.sync_complete) {
        loadingElement.classList.add('loaded');
        loadingElement.classList.remove('loading');
        clearInterval(interval);
        location.reload();
      }
    }).catch(function (error) {
      switch (error.status) {
        case 404:
          loadingElement.innerHTML = 'Could not update synchronization status, please try refreshing page';
          break;
        case 401:
          loadingElement.innerHTML = 'You are not authorized. Please check if you are properly logged in';
          break;
        case 500:
          loadingElement.innerHTML = 'Something went wrong, please try synchronizing again';
          break;
        default:
          loadingElement.innerHTML = 'An unknown error occurred. Please try again';
      }
      clearInterval(interval);
    });
  };

  if (loadingElement) {
    window.interval = setInterval(updateFunc, 500);
  }

  var tableElem = document.querySelector('.incomming-localizations-table');

  tableElem && tableElem.addEventListener('click', function (e) {
    var button = e.target;
    if (button.matches('.js-accept-btn')) {
      e.preventDefault();
      var url = e.target.href;
      fetch(url, {
        method: 'GET',
        headers: {
          'X-CSRF-Token': Rails.csrfToken(),
          'Content-Type': 'application/json'
        }
      }).then(function (_ref) {
        var ok = _ref.ok;

        if (ok) {
          button.parentElement.parentElement.remove(); // remove row
        } else {
          alert('Localization could not be accepted.');
        }
      });
    }

    if (button.matches('.js-reject-btn')) {
      e.preventDefault();
      if (confirm("Are you sure?")) {
        var _url = e.target.href;
        fetch(_url, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': Rails.csrfToken(),
            'Content-Type': 'application/json'
          }
        }).then(function (_ref2) {
          var ok = _ref2.ok;

          if (ok) {
            button.parentElement.parentElement.remove(); // remove row
          } else {
            alert('Localization could not be rejected.');
          }
        });
      }
    }
  });

  var acceptButtons = document.querySelectorAll('.js-accept-btn');
  var rejectButtons = document.querySelectorAll('.js-reject-btn');
});
});

;require.register("src/lit/backend/ui.js", function(exports, require, module) {
'use strict';

document.addEventListener('click', function (e) {
  console.log(e.target);
  if (e.target.matches('[data-toggle="dropdown"]')) {
    document._dropdownOpen = true;
    e.target.parentElement.classList.toggle('open');
  } else {
    document._dropdownOpen && document.querySelectorAll('.dropdown.open, .btn-group.open').forEach(function (dropdown) {
      return dropdown.classList.remove('open');
    });
    document._dropdownOpen = false;
  }
});
});

require.register("src/lit/utils.js", function(exports, require, module) {
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
var Utils = {
  closest: function closest(refElem, selector) {
    while (!refElem.matches(selector)) {
      refElem = refElem.parentNode;
      if (!refElem) {
        return;
      }
    }
    return refElem;
  }
};

exports.default = Utils;
});

require.register("___globals___", function(exports, require, module) {
  
});})();require('___globals___');


//# sourceMappingURL=app.js.map