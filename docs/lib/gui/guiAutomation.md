# guiAutomation.ks

Path: `0:/lib/gui/guiAutomation.ks`

## Purpose
Automation registry for armable systems. A ship/program registers each system with
a name, an arm *action*, and an optional starting AUTO/MANUAL state. Each system
has an AUTO/MANUAL switch and an armed flag. `autoArmSystems()` arms every
registered system; each system's automatic action then checks `systemManual(name)`
before firing. There is no live toggle - manual mode is fixed at `registerSystem` time.

## Imports
- `0:/lib/logging.ks` (`logMessage`). Loaded by `gui.ks` after `guiCore.ks`.

## Globals declared
- `guiSystems` - a `LIST` of registered systems, each `LEXICON("name", "action", "armed", "manual")`.

## Functions
- `registerSystem(name, action, manual)` - register a system; `action` is a no-arg delegate that performs the arming (capturing ship params). `manual` (default FALSE) starts it in manual mode.
- `findSystem(name)` - return the registered system lexicon, or `0`.
- `armSystem(name)` - arm one system now (idempotent; does nothing if already armed). Logs the arm. Called by `autoArmSystems`.
- `autoArmSystems()` - arm every registered system. The ship script calls this at post-launch where it used to arm directly.
- `systemManual(name)` - TRUE if the named system is registered and in MANUAL; autonomous code (e.g. auto-destruct) checks it before firing. Unknown systems return FALSE.

## Notes
MANUAL is set once at registration: the system stays armed but its automatic
action holds forever, so the pilot must fire it from that system's own panel. The
autonomous action must be written to consult `systemManual(name)` (see
`lib/detonation.ks`). Time-critical arming (e.g. booster separation) stays a
direct automatic call - only register systems the pilot has time to control.
Register systems before `startDashboard`. See README "Automation & manual override".
