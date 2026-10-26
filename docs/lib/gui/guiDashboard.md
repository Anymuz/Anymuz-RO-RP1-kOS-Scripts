# guiDashboard.ks

Path: `0:/lib/gui/guiDashboard.ks`

## Purpose
Top-level orchestrator that assembles panels into a mission-control window and
drives its lifecycle. This is the only GUI file a ship/program normally calls.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- `0:/lib/gui/guiPanels.ks` (loaded on demand by `guiUseStandardLayout`, not at import)

## Globals declared
- `guiLayout` - the dashboard as data: a `LIST` of rows, each `LIST("TAB", builder1@, builder2@, ...)`. `buildDashboard` walks it. **Empty by default**; fill it with the helpers below, or let `buildDashboard` fall back to the full shared layout via `guiUseStandardLayout`.

## Functions
- `buildDashboard(title, width)` - create a window and build every tab/panel listed in `guiLayout` via `guiAddTabs`. If `guiLayout` is empty, calls `guiUseStandardLayout` first.
- `guiUseStandardLayout()` - load the full shared panel bundle (`guiPanels.ks`) and populate `guiLayout` with the standard tabs. Opt-in; used by the generic fallback and sandbox.
- `startDashboard(title, refreshInterval)` - build, show, do a first refresh, arm the timed refresh, and log that the GUI is online.
- `stopDashboard()` - disarm the refresh, dispose the window, and log closure.
- `guiResetLayout()` - empty `guiLayout` so you can rebuild it from scratch.
- `guiAddTab(tabName, builders)` - append a tab: a name plus a `LIST` of panel-builder delegates that stack on it.

## Notes
For a ship/series-specific dashboard, `RUNONCEPATH` only the panels that vehicle
shows, then call `guiResetLayout()` and `guiAddTab(...)` per system, **before**
`startDashboard`. A family dashboard file under `gui/` is the natural home for
this. Load this stack after `lib/logging.ks`, `lib/utils.ks`,
`lib/resources.ks` (the RESOURCES panel needs `getResourceSummary`), and
`lib/audio.ks`.
