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

var _pell = require('pell');

var _pell2 = _interopRequireDefault(_pell);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var edited_rows = {};

document.addEventListener('DOMContentLoaded', function () {
  var localizationRows = document.querySelectorAll('td.localization_row[data-editing="0"]');

  localizationRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (parseInt(e.target.dataset.editing) === 0) {
        edited_rows[e.target.dataset.id] = e.target.innerHTML;
        var rowElem = document.querySelector('td.localization_row[data-id="' + e.target.dataset.id + '"]');
        if (!parseInt(e.target.dataset.editing)) {
          e.target.dataset.editing = '1';
          fetch(e.target.dataset.edit).then(function (resp) {
            return resp.json();
          }).then(function (_ref) {
            var html = _ref.html,
                isHtmlKey = _ref.isHtmlKey;

            rowElem.dataset.editing = 1;
            rowElem.innerHTML = html;
            rowElem.querySelector('textarea').focus();
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
                    translated_value: isHtmlKey ? rowElem.querySelector('.pell').innerHTML : rowElem.querySelector('textarea').value
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
          });
        }
      }
    });
  });

  var allLocalizationRows = document.querySelectorAll('td.localization_row');

  allLocalizationRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (e.target.matches('form button.cancel')) {
        var refElem = e.target;
        if (refElem.localName === 'button') {
          while (!refElem.matches('td.localization_row')) {
            refElem = refElem.parentNode;
            if (!refElem) {
              return;
            }
          }
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
        var refElem = e.target;
        while (!refElem.matches('tr.localization_versions_row')) {
          refElem = refElem.parentNode;
          if (!refElem) {
            return;
          }
        }
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
        var refElem = e.target;
        while (!refElem.matches('form')) {
          refElem = refElem.parentNode;
          if (!refElem) {
            return;
          }
        }
        var textarea = refElem.querySelector('.pell');
        var pellElement = refElem.querySelector('.pell');

        _pell2.default.init({
          element: pellElement,
          onChange: function onChange(html) {
            return textarea.value = html;
          }
        });
      }

      if (e.target.matches('.request_info_link')) {
        var _refElem = e.target;
        while (!_refElem.matches('tr.localization_key_row')) {
          _refElem = _refElem.parentNode;
          if (!_refElem) {
            return;
          }
        }
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
});
});

;require.register("___globals___", function(exports, require, module) {
  
});})();require('___globals___');


//# sourceMappingURL=app.js.map