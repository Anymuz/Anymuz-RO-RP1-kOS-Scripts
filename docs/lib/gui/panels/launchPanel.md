# panels/launchPanel.ks

Path: `0:/lib/gui/panels/launchPanel.ks`

## Purpose
GUI panel that commands launch from a button, with a slider to set the countdown.
A starting example of a *control* panel: it feeds the launch hold in
`lib/launch.ks` instead of doing work itself, so the ship script stays
GUI-agnostic.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- Calls `commandLaunch` and sets `launchCountdown` (both from `lib/launch.ks`).

## Globals declared
- None. Uses `launchCommanded` / `launchCountdown` owned by `lib/launch.ks`.

## Functions
- `buildLaunchPanel(parentBox)` - adds a LAUNCH section: a countdown slider **and** a typed number field (both set `launchCountdown` and stay in sync), a live T-minus/status readout, and a **LAUNCH** button wired to `commandLaunch@`.

## Notes
The button is a trigger, so it stays short: it only calls `commandLaunch()`, which
sets `launchCommanded`. The existing `initializeLaunch()` in `lib/launch.ks` waits
for that flag, so no ship-script changes are needed beyond
loading the GUI:

```
startDashboard(shipName).
initializeLaunch().   // released by the GUI LAUNCH button
countdownLaunch().    // uses launchCountdown (the slider value)
launchShip().
```

The T-minus readout is computed **GUI-side**: the updater keeps a private `clock`
lexicon, starts it on the rising edge of `launchCommanded`, and derives the count
from `launchCountdown`. Liftoff is detected from `flightData["phase"]` leaving
`"prelaunch"`. Nothing is added to `lib/launch.ks` for the display - the panel
observes existing state. See README Tutorial 11.
