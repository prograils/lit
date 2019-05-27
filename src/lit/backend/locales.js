import Utils from '../utils';

document.addEventListener('DOMContentLoaded', () => {
  const handleHideLocaleLinkClick = e => {
    e.preventDefault;
    Utils.fetch(e.target.href, {
      method: 'PUT'
    }).then(resp => resp.json())
      .then(({ hidden }) => {
        e.target.innerHTML = hidden ? 'Show' : 'Hide';
      })
  }

  document.querySelectorAll('.js-hide-locale-link')
    .forEach(link => link.addEventListener('click', handleHideLocaleLinkClick));
})