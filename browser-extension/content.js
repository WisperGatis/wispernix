// Applies the palette to the page's background colors and fixes text contrast.
// Changes are inline !important overrides tracked in a WeakMap so they can be undone.
(function () {
  "use strict";
  const M = globalThis.WebPaletteMapping;
  const MARK = "data-web-palette";
  const originals = new WeakMap(); // element -> {bg, fg}
  let palette = null;
  let enabled = false;
  let observer = null;

  function hostKey() {
    return location.hostname;
  }

  function restoreAll() {
    document.querySelectorAll(`[${MARK}]`).forEach((el) => {
      const orig = originals.get(el);
      if (orig) {
        el.style.setProperty("background-color", orig.bg.value, orig.bg.priority);
        el.style.setProperty("color", orig.fg.value, orig.fg.priority);
      }
      el.removeAttribute(MARK);
    });
  }

  function remapElement(el) {
    const cs = getComputedStyle(el);
    const bgMapped = M.mapBackground(cs.backgroundColor, palette);
    if (!bgMapped) return;
    if (!originals.has(el)) {
      originals.set(el, {
        bg: { value: el.style.getPropertyValue("background-color"), priority: el.style.getPropertyPriority("background-color") },
        fg: { value: el.style.getPropertyValue("color"), priority: el.style.getPropertyPriority("color") },
      });
    }
    el.style.setProperty("background-color", bgMapped, "important");
    const fgMapped = M.pickForeground(cs.color, bgMapped, palette);
    if (fgMapped) el.style.setProperty("color", fgMapped, "important");
    el.setAttribute(MARK, "1");
  }

  // Walks the DOM in small chunks so big pages do not freeze.
  function applyTo(root) {
    const nodes = root.querySelectorAll ? [root, ...root.querySelectorAll("*")] : [];
    let i = 0;
    function step() {
      const end = Math.min(i + 400, nodes.length);
      for (; i < end; i++) {
        if (nodes[i].nodeType === 1) remapElement(nodes[i]);
      }
      if (i < nodes.length) requestIdleCallback ? requestIdleCallback(step) : setTimeout(step, 0);
    }
    step();
  }

  function startObserver() {
    if (observer) return;
    observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        for (const node of m.addedNodes) {
          if (node.nodeType === 1) applyTo(node);
        }
      }
    });
    observer.observe(document.documentElement, { childList: true, subtree: true });
  }

  function stopObserver() {
    if (observer) observer.disconnect();
    observer = null;
  }

  function update(state) {
    palette = state.palette ? M.preparePalette(state.palette) : null;
    enabled = !!(palette && state.enabled !== false && !(state.disabledSites || []).includes(hostKey()));
    restoreAll();
    stopObserver();
    if (enabled) {
      applyTo(document.documentElement);
      startObserver();
    }
  }

  chrome.storage.local.get(["palette", "enabled", "disabledSites"]).then(update);
  chrome.storage.onChanged.addListener((changes, area) => {
    if (area !== "local") return;
    chrome.storage.local.get(["palette", "enabled", "disabledSites"]).then(update);
  });
})();
