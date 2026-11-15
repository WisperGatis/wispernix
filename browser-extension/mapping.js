// Pure color logic for the web-palette extension. No DOM, no chrome.* APIs,
// so it runs under Node for tests and is loaded as a plain script in the browser.
(function (root) {
  "use strict";

  // Parses "#rrggbb", "#rgb", "rgb(r, g, b)" or "rgba(r, g, b, a)".
  // Returns {r,g,b,a} (0-255, alpha 0-1) or null when unparseable.
  function parseColor(input) {
    if (typeof input !== "string") return null;
    const s = input.trim().toLowerCase();
    let m = s.match(/^#([0-9a-f]{3})$/);
    if (m) {
      const [r, g, b] = m[1].split("").map((c) => parseInt(c + c, 16));
      return { r, g, b, a: 1 };
    }
    m = s.match(/^#([0-9a-f]{6})$/);
    if (m) {
      return {
        r: parseInt(m[1].slice(0, 2), 16),
        g: parseInt(m[1].slice(2, 4), 16),
        b: parseInt(m[1].slice(4, 6), 16),
        a: 1,
      };
    }
    m = s.match(/^rgba?\(\s*([\d.]+)[,\s]+([\d.]+)[,\s]+([\d.]+)(?:[,\s/]+([\d.]+%?))?\s*\)$/);
    if (m) {
      let a = 1;
      if (m[4] !== undefined) a = m[4].endsWith("%") ? parseFloat(m[4]) / 100 : parseFloat(m[4]);
      return { r: +m[1], g: +m[2], b: +m[3], a };
    }
    return null;
  }

  function toHex({ r, g, b }) {
    const h = (v) => Math.round(Math.min(255, Math.max(0, v))).toString(16).padStart(2, "0");
    return "#" + h(r) + h(g) + h(b);
  }

  // sRGB -> CIE Lab (D65).
  function toLab({ r, g, b }) {
    const lin = (c) => {
      c /= 255;
      return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    };
    const R = lin(r), G = lin(g), B = lin(b);
    let X = (R * 0.4124 + G * 0.3576 + B * 0.1805) / 0.95047;
    let Y = R * 0.2126 + G * 0.7152 + B * 0.0722;
    let Z = (R * 0.0193 + G * 0.1192 + B * 0.9505) / 1.08883;
    const f = (t) => (t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116);
    const fx = f(X), fy = f(Y), fz = f(Z);
    return { L: 116 * fy - 16, a: 500 * (fx - fy), b: 200 * (fy - fz) };
  }

  function deltaE(l1, l2) {
    return Math.hypot(l1.L - l2.L, l1.a - l2.a, l1.b - l2.b);
  }

  // WCAG relative luminance and contrast ratio.
  function luminance({ r, g, b }) {
    const lin = (c) => {
      c /= 255;
      return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    };
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
  }

  function contrastRatio(c1, c2) {
    const l1 = luminance(c1), l2 = luminance(c2);
    const [hi, lo] = l1 > l2 ? [l1, l2] : [l2, l1];
    return (hi + 0.05) / (lo + 0.05);
  }

  // Chroma (distance from gray in Lab). Low chroma = neutral background.
  function chroma(lab) {
    return Math.hypot(lab.a, lab.b);
  }

  // Normalizes a palette object into parsed colors and a dark flag.
  // Background ramp = surface roles sorted by lightness (darkest first).
  function preparePalette(raw) {
    const keys = ["surface", "surface_container", "surface_container_high"];
    const ramp = keys
      .map((k) => parseColor(raw[k]))
      .filter(Boolean)
      .map((c) => ({ rgb: c, lab: toLab(c) }))
      .sort((x, y) => x.lab.L - y.lab.L);
    const fg = parseColor(raw.on_surface) || { r: 255, g: 255, b: 255, a: 1 };
    const accent = parseColor(raw.primary);
    const dark = ramp.length ? ramp[0].lab.L < 50 : true;
    return { ramp, fg, accent, dark };
  }

  // Maps one page background color to the palette ramp.
  // - transparent / unparseable: returns null (leave untouched)
  // - colored (chroma above threshold): returns null (brand buttons, badges stay)
  // - neutral: picks the ramp entry whose lightness is closest to the page's
  //   lightness, so light pages stay light and dark pages stay dark.
  function mapBackground(input, palette, options = {}) {
    const chromaMax = options.chromaMax ?? 18;
    const c = parseColor(input);
    if (!c || c.a === 0 || !palette.ramp.length) return null;
    const lab = toLab(c);
    if (chroma(lab) > chromaMax) return null;
    let best = palette.ramp[0];
    let bestDist = Infinity;
    for (const entry of palette.ramp) {
      const d = Math.abs(entry.lab.L - lab.L);
      if (d < bestDist) {
        best = entry;
        bestDist = d;
      }
    }
    return toHex(best.rgb);
  }

  // Chooses a foreground for a remapped background. Keeps the site's own text
  // color when contrast is already acceptable, otherwise uses the palette
  // on_surface color, then falls back to black or white.
  function pickForeground(textInput, bgHex, palette, minRatio = 4.5) {
    const text = parseColor(textInput);
    const bg = parseColor(bgHex);
    if (!text || !bg) return null;
    if (contrastRatio(text, bg) >= minRatio) return null;
    const candidates = [palette.fg, { r: 0, g: 0, b: 0, a: 1 }, { r: 255, g: 255, b: 255, a: 1 }];
    let best = candidates[0];
    let bestRatio = -1;
    for (const cand of candidates) {
      const ratio = contrastRatio(cand, bg);
      if (ratio >= minRatio) return toHex(cand);
      if (ratio > bestRatio) {
        best = cand;
        bestRatio = ratio;
      }
    }
    return toHex(best);
  }

  const api = {
    parseColor,
    toHex,
    toLab,
    deltaE,
    luminance,
    contrastRatio,
    preparePalette,
    mapBackground,
    pickForeground,
  };

  if (typeof module !== "undefined" && module.exports) module.exports = api;
  else root.WebPaletteMapping = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
