# panels/telemetryPanel.ks

Path: `0:/lib/gui/panels/telemetryPanel.ks`

## Purpose
GUI panel showing live, read-only vessel telemetry. One aspect per file so panels
can be composed independently.

## Imports
- `0:/lib/gui/guiCore.ks` (factories/registry)
- `0:/lib/gui/guiTheme.ks` (formatting)
- Reads `SHIP` and `flightData`; uses `formatTime`/`getLogTime` (`lib/logging.ks`).

## Globals declared
- None.

## Functions
- `buildTelemetryPanel(parentBox)` - adds a TELEMETRY section (mission time, altitude, vertical/surface speed, apoapsis, phase) and registers an updater sampling `SHIP`/`flightData` each refresh.

## Notes
`parentBox` defaults to `guiState["window"]`. Mission time uses `getLogTime()`, so
call `setLogToShipTime(...)` at launch for a launch-relative clock.
