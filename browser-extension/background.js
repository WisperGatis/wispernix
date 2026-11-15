// Polls the local palette service and mirrors it into chrome.storage.local.
// Content scripts react to storage changes, so open tabs update live.
const PALETTE_URL = "http://127.0.0.1:8765/palette.json";

async function refreshPalette() {
  try {
    const res = await fetch(PALETTE_URL, { cache: "no-store" });
    if (!res.ok) return;
    const palette = await res.json();
    const { palette: previous } = await chrome.storage.local.get("palette");
    if (JSON.stringify(previous) !== JSON.stringify(palette)) {
      await chrome.storage.local.set({ palette });
    }
  } catch (_) {
    // Service not running: keep the last known palette.
  }
}

// MV3 alarms cannot fire faster than 30 s, so the worker also polls on wake-up.
chrome.runtime.onInstalled.addListener(() => {
  chrome.alarms.create("web-palette", { periodInMinutes: 0.5 });
  refreshPalette();
});
chrome.runtime.onStartup.addListener(refreshPalette);
chrome.alarms.onAlarm.addListener((a) => {
  if (a.name === "web-palette") refreshPalette();
});
