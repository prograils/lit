const Utils = {
  closest: (refElem, selector) => {
    while (!refElem.matches(selector)) {
      refElem = refElem.parentNode;
      if (!refElem) { return; }
    }
    return refElem;
  },

  fetch: (resource, init) => {
    return global.fetch(
      resource,
      Object.assign({}, {
        headers: {
          'X-CSRF-Token': Rails.csrfToken(),
          'Content-Type': 'application/json'
        }
      }, init)
    );
  }
}

export default Utils;