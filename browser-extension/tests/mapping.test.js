const test = require("node:test");
const assert = require("node:assert/strict");
const M = require("../mapping.js");

const dark = M.preparePalette({
  surface: "#1e1e2e",
  surface_container: "#313244",
  surface_container_high: "#45475a",
  on_surface: "#cdd6f4",
  primary: "#cba6f7",
});
const light = M.preparePalette({
  surface: "#fbf8ff",
  surface_container: "#efe7f5",
  surface_container_high: "#e9e1ee",
  on_surface: "#1d1a22",
  primary: "#6750a4",
});

test("parseColor handles hex, short hex, rgb and rgba", () => {
  assert.deepEqual(M.parseColor("#ff8000"), { r: 255, g: 128, b: 0, a: 1 });
  assert.deepEqual(M.parseColor("#f80"), { r: 255, g: 136, b: 0, a: 1 });
  assert.deepEqual(M.parseColor("rgb(10, 20, 30)"), { r: 10, g: 20, b: 30, a: 1 });
  assert.deepEqual(M.parseColor("rgba(10, 20, 30, 0.5)"), { r: 10, g: 20, b: 30, a: 0.5 });
  assert.equal(M.parseColor("transparent"), null);
});

test("lab of white is about L=100 and of black is L=0", () => {
  assert.ok(Math.abs(M.toLab({ r: 255, g: 255, b: 255 }).L - 100) < 0.1);
  assert.ok(Math.abs(M.toLab({ r: 0, g: 0, b: 0 }).L) < 0.1);
});

test("contrast ratio of black on white is 21", () => {
  const r = M.contrastRatio({ r: 0, g: 0, b: 0 }, { r: 255, g: 255, b: 255 });
  assert.ok(Math.abs(r - 21) < 0.01);
});

test("dark palette detected from surface lightness", () => {
  assert.equal(dark.dark, true);
  assert.equal(light.dark, false);
});

test("neutral white page on dark palette maps to a dark surface", () => {
  const out = M.mapBackground("#ffffff", dark);
  assert.ok(out, "expected a mapped color");
  assert.ok(M.toLab(M.parseColor(out)).L < 50, `got ${out}`);
});

test("neutral dark page on light palette maps to a light surface", () => {
  const out = M.mapBackground("#101010", light);
  assert.ok(M.toLab(M.parseColor(out)).L > 50, `got ${out}`);
});

test("saturated backgrounds are left alone", () => {
  assert.equal(M.mapBackground("#ff0000", dark), null);
  assert.equal(M.mapBackground("#0066ff", light), null);
});

test("transparent and unparseable backgrounds are left alone", () => {
  assert.equal(M.mapBackground("rgba(0, 0, 0, 0)", dark), null);
  assert.equal(M.mapBackground("inherit", dark), null);
});

test("mapped background stays within the palette ramp", () => {
  const allowed = ["#1e1e2e", "#313244", "#45475a"];
  for (const input of ["#fafafa", "#888888", "#222222", "#eeeeee"]) {
    assert.ok(allowed.includes(M.mapBackground(input, dark)), input);
  }
});

test("foreground is kept when contrast is already fine", () => {
  assert.equal(M.pickForeground("#000000", "#ffffff", light), null);
});

test("foreground is fixed when text would vanish on the new background", () => {
  // Dark grey text on the dark palette surface: too little contrast.
  const fg = M.pickForeground("#3a3a3a", "#1e1e2e", dark);
  assert.ok(fg, "expected a replacement");
  assert.ok(M.contrastRatio(M.parseColor(fg), M.parseColor("#1e1e2e")) >= 4.5);
});
