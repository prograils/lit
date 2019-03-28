"use strict";

document.addEventListener('DOMContentLoaded', function () {
  var loadingElement = document.querySelector('.loading');

  var updateFunc = function updateFunc() {
    var sourceIdElement = document.querySelector('#source_id');

    if (!sourceIdElement) {
      return;
    }

    var sourceId = sourceIdElement.value;
    fetch("/lit/sources/".concat(sourceId, "/sync_complete")).then(function (resp) {
      if (resp.ok) {
        return resp.json();
      } else {
        return Promise.reject({
          status: resp.status
        });
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