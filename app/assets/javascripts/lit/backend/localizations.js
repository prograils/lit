"use strict";

var edited_rows = {};
document.addEventListener('DOMContentLoaded', function () {
  var localizationRows = document.querySelectorAll('td.localization_row[data-editing="0"]');
  localizationRows.forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (parseInt(e.target.dataset.editing) === 0) {
        edited_rows[e.target.dataset.id] = e.target.innerHTML;

        if (!parseInt(e.target.dataset.editing)) {
          e.target.dataset.editing = '1';
          fetch(e.target.dataset.edit);
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