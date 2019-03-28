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
})