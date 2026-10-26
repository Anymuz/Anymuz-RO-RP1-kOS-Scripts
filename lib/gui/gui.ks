// GUI TOOLKIT
// Aggregator loader for theme, core, automation, and dashboard. See docs/lib/gui/.
// --------------------------------------------------------------

RUNONCEPATH("0:/lib/gui/guiTheme.ks").      // Colours, sizes, rich-text helpers.
RUNONCEPATH("0:/lib/gui/guiCore.ks").       // Window lifecycle, widget registry, refresh loop.
RUNONCEPATH("0:/lib/gui/guiAutomation.ks"). // Armable-system registry (auto/manual override).
RUNONCEPATH("0:/lib/gui/guiDashboard.ks").  // Generic fallback dashboard and lifecycle helpers.
