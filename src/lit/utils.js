const Utils = {
  closest: (refElem, selector) => {
    while (!refElem.matches(selector)) {
      refElem = refElem.parentNode;
      if (!refElem) { return; }
    }
    return refElem;
  }
}

export default Utils;