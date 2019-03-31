let edited_rows = {};

document.addEventListener('DOMContentLoaded', () => {
  const localizationRows = document.querySelectorAll('td.localization_row[data-editing="0"]');

  localizationRows.forEach(row => {
    row.addEventListener('click', e => {
      if (parseInt(e.target.dataset.editing) === 0) {
        edited_rows[e.target.dataset.id] = e.target.innerHTML;
        if (!parseInt(e.target.dataset.editing)) {
          e.target.dataset.editing = '1';
          fetch(e.target.dataset.edit);
        }
      }
    })
  });

  const allLocalizationRows = document.querySelectorAll('td.localization_row');

  allLocalizationRows.forEach(row => {
    row.addEventListener('click', e => {
      if (e.target.matches('form button.cancel')) {
        let refElem = e.target;
        if (refElem.localName === 'button') {
          while (!refElem.matches('td.localization_row')) {
            refElem = refElem.parentNode;
            if (!refElem) { return; }
          }
          refElem.dataset.editing = '0';
          refElem.innerHTML = edited_rows[refElem.dataset.id];
          e.preventDefault();
          return false;
        }
      }
    })
  });

  const localizationVersionsRows = document.querySelectorAll('tr.localization_versions_row');

  localizationVersionsRows.forEach(row => {
    row.addEventListener('click', e => {
      if (e.target.matches('.close_versions')) {
        let refElem = e.target;
        while (!refElem.matches('tr.localization_versions_row')) {
          refElem = refElem.parentNode;
          if (!refElem) { return; }
        }
        refElem.classList.add('hidden');
        refElem.querySelectorAll('td').forEach(td => td.innerHTML = '');
      }
    })
  });

  const localizationKeyRows = document.querySelectorAll('tr.localization_key_row');

  localizationKeyRows.forEach(row => {
    row.addEventListener('click', e => {
      if (e.target.matches('input.wysiwyg_switch')) {
        let refElem = e.target;
        while (!refElem.matches('form')) {
          refElem = refElem.parentNode;
          if (!refElem) { return; }
        }
        textarea = refElem.querySelector('textarea');
        $.fn.jqte(textarea);
      }

      if (e.target.matches('.request_info_link')) {
        let refElem = e.target;
        while (!refElem.matches('tr.localization_key_row')) {
          refElem = refElem.parentNode;
          if (!refElem) { return; }
        }
        requestInfoRow = refElem.querySelector('.request_info_row');
        if (requestInfoRow.classList.contains('hidden')) {
          requestInfoRow.classList.remove('hidden');
        } else {
          requestInfoRow.classList.add('hidden');
        }
      }
    });
  });
})