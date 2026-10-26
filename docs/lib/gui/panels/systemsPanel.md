# panels/systemsPanel.ks

Path: `0:/lib/gui/panels/systemsPanel.ks`

## Purpose
GUI panel showing read-only systems health: colour-coded electric charge and the
current alarm state.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- `0:/lib/resources.ks` (`getResourceAmount`, `getResourcePercent`)
- Reads `alarmState` (`lib/audio.ks`).

## Globals declared
- None.

## Functions
- `buildSystemsPanel(parentBox)` - adds a SYSTEMS section (electric charge, alarm) and registers an updater that colours the charge (`NOMINAL`/`WARNING`/`CRITICAL`) and reports the alarm.

## Notes
`parentBox` defaults to `guiState["window"]`. Charge amount/percent come from `getResourceAmount("ElectricCharge")` / `getResourcePercent("ElectricCharge")` (whole-ship, tag-less); tune the warning/critical thresholds in the updater if desired.
