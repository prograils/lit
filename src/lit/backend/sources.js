import Utils from '../utils';

document.addEventListener('DOMContentLoaded', () => {
  const loadingElement = document.querySelector('.loading');

  const updateFunc = () => {
    const sourceIdElement = document.querySelector('#source_id');
    if (!sourceIdElement) { return; }

    const sourceId = sourceIdElement.value;

    fetch(`/lit/sources/${sourceId}/sync_complete`)
      .then(resp => {
        if (resp.ok) {
          return resp.json();
        } else {
          return Promise.reject({ status: resp.status });
        }
      })
      .then(json => {
        if (json.sync_complete) {
          loadingElement.classList.add('loaded');
          loadingElement.classList.remove('loading');
          clearInterval(interval);
          location.reload();
        }
      })
      .catch(error => {
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
            loadingElement.innerHTML = 'An unknown error occurred. Please try again'
        }
        clearInterval(interval);
      });
  }

  if (loadingElement) {
    window.interval = setInterval(updateFunc, 500);
  }

  const tableElem = document.querySelector('.incomming-localizations-table');

  tableElem && tableElem.addEventListener('click', e => {
    const button = e.target;
    if (button.matches('.js-accept-btn')) {
      e.preventDefault();
      const url = e.target.href;
      Utils.fetch(url, {
        method: 'GET'
      })
        .then(({ ok }) => {
          if (ok) {
            button.parentElement.parentElement.remove(); // remove row
          } else {
            alert('Localization could not be accepted.');
          }
        })
    }

    if (button.matches('.js-reject-btn')) {
      e.preventDefault();
      if (confirm("Are you sure?")) {
        const url = e.target.href;
        Utils.fetch(url, {
          method: 'DELETE'
        })
          .then(({ ok }) => {
            if (ok) {
              button.parentElement.parentElement.remove(); // remove row
            } else {
              alert('Localization could not be rejected.');
            }
          })
      }
    }
  });

  const acceptButtons = document.querySelectorAll('.js-accept-btn');
  const rejectButtons = document.querySelectorAll('.js-reject-btn');
})