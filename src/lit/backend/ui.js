document.addEventListener('click', e => {
  if (e.target.matches('[data-toggle="dropdown"]')) {
    document._dropdownOpen = true;
    e.target.parentElement.classList.toggle('open');
  } else {
    document._dropdownOpen && document.querySelectorAll('.dropdown.open, .btn-group.open').forEach(dropdown => dropdown.classList.remove('open'));
    document._dropdownOpen = false;
  }
});