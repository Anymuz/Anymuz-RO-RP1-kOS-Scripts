# panels/controlsPanel.ks

Path: `0:/lib/gui/panels/controlsPanel.ks`

## Purpose
GUI panel of operator action buttons wired to existing library functions.

## Imports
- `0:/lib/gui/guiCore.ks`
- Calls `stopAlarmSound` (`lib/audio.ks`) and `outputFlightData` (`lib/utils.ks`).

## Globals declared
- None.

## Functions
- `buildControlsPanel(parentBox)` - adds a CONTROLS section with **Silence Alarm** and **Dump Data** buttons on one row.

## Notes
`parentBox` defaults to `guiState["window"]`. Kept to safe, operator-initiated,
reversible actions. Add more with `guiAddButton`; keep destructive actions
(abort, staging, self-destruct) behind a confirm step.
