import pell from 'pell';
import Utils from '../utils';

let edited_rows = {};

document.addEventListener('DOMContentLoaded', () => {
  const localizationRows = document.querySelectorAll('td.localization_row[data-editing="0"]');

  localizationRows.forEach(row => {
    row.addEventListener('click', e => {
      const tdElem = e.currentTarget;
      if (!parseInt(tdElem.dataset.editing)) {
        edited_rows[tdElem.dataset.id] = tdElem.innerHTML;
        const rowElem = document.querySelector(`td.localization_row[data-id="${tdElem.dataset.id}"]`);
        if (!parseInt(tdElem.dataset.editing) && tdElem.dataset.edit) {
          tdElem.dataset.editing = '1';
          fetch(tdElem.dataset.edit)
            .then(resp => resp.json())
            .then(({ html, isHtmlKey }) => {
              rowElem.dataset.editing = 1;
              rowElem.innerHTML = html;
              rowElem.querySelector('textarea, input').focus();
              if (isHtmlKey) {
                rowElem.querySelector('.wysiwyg_switch').click()
              }

              rowElem.querySelector('form').addEventListener('submit', e => {
                const url = e.target.action;
                Utils.fetch(url, {
                  method: 'PATCH',
                  body: JSON.stringify({
                    localization: {
                      translated_value: rowElem.querySelector('textarea').value
                    }
                  })
                })
                  .then(resp => resp.json())
                  .then(({ localizationId, html }) => {
                    delete rowElem.dataset.editing;
                    rowElem.innerHTML = html;
                    rowElem.parentElement.querySelector('.show_prev_versions').classList.remove('hidden');
                    document.querySelector(`a.change_completed_${localizationId} input[type="checkbox"]`).checked = true;
                  })
                e.preventDefault();
              });

              const handleCloudTranslationLinkClick = e => {
                e.preventDefault();
                const url = e.target.href;
                Utils.fetch(url).then(resp => resp.json()).then(
                  ({ translatedText }) => {
                    if (typeof (translatedText) === 'string') {
                      const textareaElem = rowElem.querySelector('textarea');
                      textareaElem.value = translatedText;
                      if (isHtmlKey) {
                        const pellElement = rowElem.querySelector('.pell');
                        pellElement.content.innerHTML = translatedText;
                      }
                    } else if (typeof (translatedText) === 'object') {
                      const inputElems = rowElem.querySelectorAll('input[type="text"]');
                      inputElems.forEach((inputElem, i) => inputElem.value = translatedText[i]);
                    }
                  }
                );
              }

              rowElem.querySelectorAll('.js-cloud-translation-link').forEach(link => {
                link.addEventListener('click', handleCloudTranslationLinkClick);
              });
            });
        }
      }
    })
  });

  const allLocalizationRows = document.querySelectorAll('td.localization_row');

  allLocalizationRows.forEach(row => {
    row.addEventListener('click', e => {
      if (e.target.matches('form button.cancel')) {
        if (e.target.localName === 'button') {
          const refElem = Utils.closest(e.target, 'td.localization_row');
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
        const refElem = Utils.closest(e.target, 'tr.localization_versions_row');
        refElem.classList.add('hidden');
        refElem.querySelectorAll('td').forEach(td => td.innerHTML = '');
      }
    })
  });

  const localizationKeyRows = document.querySelectorAll('tr.localization_key_row');

  localizationKeyRows.forEach(row => {
    row.addEventListener('click', e => {
      if (e.target.matches('input.wysiwyg_switch')) {
        const refElem = Utils.closest(e.target, 'form');
        const textarea = refElem.querySelector('textarea');
        const pellElement = refElem.querySelector('.pell');

        if (e.target.checked) {
          if (!pellElement.content) {
            pell.init({
              element: pellElement,
              defaultParagraphSeparator: '',
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
        const refElem = Utils.closest(e.target, 'tr.localization_key_row');
        requestInfoRow = refElem.querySelector('.request_info_row');
        if (requestInfoRow.classList.contains('hidden')) {
          requestInfoRow.classList.remove('hidden');
        } else {
          requestInfoRow.classList.add('hidden');
        }
      }
    });

    const handleDeleteLinkClick = (e) => {
      e.preventDefault();
      const link = Utils.closest(e.target, 'a');
      if (confirm(link.dataset.litConfirm)) {
        Utils.fetch(link.href, { method: 'DELETE' })
          .then(() => Utils.closest(link, 'tr').remove());
      }
    }

    const handleRestoreLinkClick = (e) => {
      e.preventDefault();
      const link = Utils.closest(e.target, 'a');
      Utils.fetch(link.href, { method: 'PUT' })
        .then(() => Utils.closest(link, 'tr').remove());
    }

    const handleStarLinkClick = (e) => {
      e.preventDefault();
      const link = Utils.closest(e.target, 'a');
      Utils.fetch(link.href, { method: 'GET' })
        .then(resp => resp.json())
        .then(({ starred }) => {
          const icon = link.querySelector('i');
          if (starred) {
            icon.classList.add('fa-star');
            icon.classList.remove('fa-star-o');
          } else {
            icon.classList.add('fa-star-o');
            icon.classList.remove('fa-star');
          }
        });
    }

    const handleCompleteLinkClick = (e) => {
      e.preventDefault();
      const link = Utils.closest(e.target, 'a');
      Utils.fetch(link.href, { method: 'PUT' })
        .then(resp => resp.json())
        .then(({ completed }) => {
          const icon = link.querySelector('i');
          if (completed) {
            icon.classList.add('fa-check-circle');
            icon.classList.remove('fa-check-circle-o');
          } else {
            icon.classList.add('fa-check-circle-o');
            icon.classList.remove('fa-check-circle');
          }
          Utils.closest(link, 'tr').querySelectorAll('input[type="checkbox"]').forEach(checkbox => checkbox.checked = completed);
        });
    }

    row.querySelectorAll('.js-delete-localization-key')
      .forEach(deleteLink => deleteLink.addEventListener('click', handleDeleteLinkClick));

    row.querySelectorAll('.js-restore-localization-key')
      .forEach(restoreLink => restoreLink.addEventListener('click', handleRestoreLinkClick));

    row.querySelectorAll('.js-star-localization-key')
      .forEach(starLink => starLink.addEventListener('click', handleStarLinkClick));

    row.querySelectorAll('.js-complete-localization-key')
      .forEach(completeLink => completeLink.addEventListener('click', handleCompleteLinkClick));
  });
})