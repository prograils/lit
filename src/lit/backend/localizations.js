import pell from 'pell';

let edited_rows = {};

document.addEventListener('DOMContentLoaded', () => {
  const localizationRows = document.querySelectorAll('td.localization_row[data-editing="0"]');

  localizationRows.forEach(row => {
    row.addEventListener('click', e => {
      if (!parseInt(e.target.dataset.editing)) {
        edited_rows[e.target.dataset.id] = e.target.innerHTML;
        const rowElem = document.querySelector(`td.localization_row[data-id="${e.target.dataset.id}"]`);
        if (!parseInt(e.target.dataset.editing)) {
          e.target.dataset.editing = '1';
          fetch(e.target.dataset.edit)
          .then(resp => resp.json())
          .then(({html, isHtmlKey}) => {
            rowElem.dataset.editing = 1;
            rowElem.innerHTML = html;
            rowElem.querySelector('textarea').focus();
            if (isHtmlKey) {
              rowElem.querySelector('.wysiwyg_switch').click()
            }
            rowElem.querySelector('form').addEventListener('submit', e => {
              const url = e.target.action;
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
              })
              .then(resp => resp.json())
              .then(({localizationId, html}) => {
                delete rowElem.dataset.editing;
                rowElem.innerHTML = html;
                rowElem.parentElement.querySelector('.show_prev_versions').classList.remove('hidden');
                document.querySelector(`a.change_completed_${localizationId} input[type="checkbox"]`).checked = true;
              })
              e.preventDefault();
            })
          });
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
        const textarea = refElem.querySelector('textarea');
        const pellElement = refElem.querySelector('.pell');

        if (e.target.checked) {
          if (!pellElement.content) {
            pell.init({
              element: pellElement,
              onChange: html => textarea.value = html
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