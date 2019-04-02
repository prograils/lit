"use strict";

var edited_rows = {};
document.addEventListener('DOMContentLoaded', function () {
  var localizationRows = document.querySelectorAll('td.localization_row[data-editing="0"]');
  localizationRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (parseInt(e.target.dataset.editing) === 0) {
        edited_rows[e.target.dataset.id] = e.target.innerHTML;
        var rowElem = document.querySelector("td.localization_row[data-id=\"".concat(e.target.dataset.id, "\"]"));

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
                debugger;
                document.querySelector("a.change_completed_".concat(localizationId, " input[type=\"checkbox\"]")).checked = true;
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

        textarea = refElem.querySelector('textarea');
        $.fn.jqte(textarea);
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