document.addEventListener('DOMContentLoaded', () => {
  const handleHideLocaleLinkClick = e => {
    e.preventDefault;
    fetch(e.target.href, {
      method: 'PUT',
      headers: {
        'X-CSRF-Token': Rails.csrfToken(),
        'Content-Type': 'application/json'
      }
    }).then(resp => resp.json())
      .then(({ hidden }) => {
        e.target.innerHTML = hidden ? 'Show' : 'Hide';
      })
  }

  document.querySelectorAll('.js-hide-locale-link')
    .forEach(link => link.addEventListener('click', handleHideLocaleLinkClick));
})