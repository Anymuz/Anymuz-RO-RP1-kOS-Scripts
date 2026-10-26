# panels/flightDataPanel.ks

Path: `0:/lib/gui/panels/flightDataPanel.ks`

## Purpose
GUI panel showing captured peak flight statistics plus a log-dump action button.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- Reads `flightData` (written by `lib/tracking.ks`); calls `outputFlightData` (`lib/utils.ks`).

## Globals declared
- None.

## Functions
- `buildFlightDataPanel(parentBox)` - adds a FLIGHT DATA section (max velocity, apogee altitude, max predicted apoapsis) and a **Dump Flight Data To Log** button.

## Notes
`parentBox` defaults to `guiState["window"]`. The dump button uses the callback
technique (`Button:ONCLICK` -> `outputFlightData@`).
