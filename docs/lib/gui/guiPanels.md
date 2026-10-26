# guiPanels.ks

Path: `0:/lib/gui/guiPanels.ks`

## Purpose
Opt-in aggregator that loads the full set of shared GUI panels. Each panel controls
a different aspect of the vessel and lives in its own file under `lib/gui/panels/`,
so panels can be added, removed, or reordered independently. This file just
`RUNONCEPATH`s them all.

**Not auto-loaded by `gui.ks`.** Purpose-built families load only the panels they
show (via `RUNONCEPATH` in `gui/<family>.ks`). This bundle is pulled in for the
full set by the sandbox and by `guiUseStandardLayout()` in `guiDashboard.ks`.

## Imports
- `0:/lib/gui/panels/telemetryPanel.ks`
- `0:/lib/gui/panels/flightDataPanel.ks`
- `0:/lib/gui/panels/enginePanel.ks`
- `0:/lib/gui/panels/resourcesPanel.ks`
- `0:/lib/gui/panels/systemsPanel.ks`
- `0:/lib/gui/panels/launchPanel.ks`
- `0:/lib/gui/panels/recoveryPanel.ks`
- `0:/lib/gui/panels/automationPanel.ks`
- `0:/lib/gui/panels/audioPanel.ks`
- `0:/lib/gui/panels/controlsPanel.ks`

## Globals declared
- None.

## Functions
- None directly. Loading this file makes the panel builders available: `buildTelemetryPanel`, `buildFlightDataPanel`, `buildEnginePanel`, `buildResourcesPanel`, `buildSystemsPanel`, `buildLaunchPanel`, `buildRecoveryPanel`, `buildAutomationPanel`, `buildAudioPanel`, `buildControlsPanel`. (`panels/paramsPanel.ks` is deprecated and no longer loaded here - see that file's own doc.)

## Panel files
| File | Builder | Aspect |
| --- | --- | --- |
| `panels/telemetryPanel.ks` | `buildTelemetryPanel` | Live telemetry (read-only). |
| `panels/flightDataPanel.ks` | `buildFlightDataPanel` | Captured peak stats + log dump. |
| `panels/enginePanel.ks` | `buildEnginePanel` | Engine thrust / TWR / ignition readouts. |
| `panels/resourcesPanel.ks` | `buildResourcesPanel` | Ship-wide resource overview (auto-discovered). |
| `panels/systemsPanel.ks` | `buildSystemsPanel` | Power + alarm health. |
| `panels/launchPanel.ks` | `buildLaunchPanel` | Launch command (control example). |
| `panels/recoveryPanel.ks` | `buildRecoveryPanel` | Recovery status + guarded manual actions. |
| `panels/automationPanel.ks` | `buildAutomationPanel` | Auto/manual arming override. |
| `panels/audioPanel.ks` | `buildAudioPanel` | Audio test bench. |
| `panels/controlsPanel.ks` | `buildControlsPanel` | Operator action buttons. |

## Notes
Load order here only affects the default appearance order in a composed
dashboard, not whether a builder is defined. Add a new shared panel by dropping a
file in `panels/`, adding one `RUNONCEPATH` line here, and `RUNONCEPATH`ing it in
each `gui/<family>.ks` that shows it.

