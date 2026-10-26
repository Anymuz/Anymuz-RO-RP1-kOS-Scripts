# launch.ks

Path: `0:/lib/launch.ks`

## Purpose
Launch sequencing. Two ignition styles are supported: a simultaneous main-engine + booster ignition for cluster-style first stages, and a clamp-held liquid ignition that releases the clamp only after a stable TWR is confirmed. Also provides the standby prompt and the countdown.

## Globals declared
- `launchCommanded` - Boolean launch-hold flag. `initializeLaunch()` clears then waits on it; `commandLaunch()` (or a keypress) releases it.
- `launchCountdown` - default countdown seconds used by `countdownLaunch()` when no argument is given. A GUI slider may adjust it.

## Functions

### Sequencing
- `commandLaunch()` - release the launch hold. A hook for a GUI button / action group; equivalent to pressing a key at the standby prompt.
- `initializeLaunch()` - standby hold that waits for a keypress **or** `commandLaunch()`, then the audible launch-commencing alert.
- `countdownLaunch(seconds)` - on-screen countdown with a tone every second. `seconds` defaults to `launchCountdown`.

### Simple launch
- `launchShip(syncIgnition)` - first-stage ignition. Sets `flightData["phase"]` to `prelaunch`, locks throttle and steering, calls `STAGE`, plays launch sound. `syncIgnition` (default FALSE) picks the ignition mode and **must match the craft's staging**:
  - `FALSE` (simultaneous) - the first `STAGE` lights the main engine and boosters together; phase is set straight to `main` so `armBoosterSeperation` skips its main-engine ignition trigger.
  - `TRUE` (sequential) - the first `STAGE` lights only the boosters; phase is left at `booster` so `armBoosterSeperation`'s Trigger A ignites the main engine once booster fuel falls to `preigniteMainThreshold`.

  A family may expose this as an `ignitionSync` global or runtime toggle and use its SYSTEMS panel to enable or disable sequential ignition settings.

### Clamp-held tagged-engine helpers (pure)
- `getTaggedEngineThrust(engineTag)` - sum of current thrust across tagged engines.
- `getTaggedEngineMaxThrust(engineTag)` - sum of max thrust across tagged engines.
- `getTaggedEngineTWR(engineTag)` - current thrust / weight using `CONSTANT:G0`.
- `taggedEnginesHaveFlameout(engineTag)` - TRUE if any tagged engine reports flameout.
- `taggedEnginesHaveIgnitionSignal(engineTag)` - TRUE if any tagged engine signals ignition.
- `countTaggedEngines(engineTag)` - number of parts with the tag.

### Clamp-held ignition flow
- `checkClampHeldEngineHealth(engineTag, minimumThrust)` - lightweight prelaunch sanity check (engine present, no flameout). Returns FALSE on hard failures.
- `waitForClampReleaseReadiness(engineTag, fuelTankTag, releaseTWR, maxClampWait, stableHoldTime, maxTWRDrop, requireFuelDrain, resourceCheckDelay)` - polls TWR and fuel drain after ignition. Fuel is read as a whole-tank total via `getResourceAmount("", fuelTankTag)` (see `lib/resources.ks`), so no resource names are needed. Aborts on flameout, thrust decay, missing fuel drain, or timeout. Returns TRUE when stable TWR is held for `stableHoldTime`.
- `launchShipClampTWR(engineTag, fuelTankTag, releaseTWR, maxClampWait, launchAzimuth, requireFuelDrain)` - the full clamp-held sequence: ignition stage, readiness wait, clamp release. Returns FALSE on abort so the ship script can skip post-launch arming.

## Notes
RO engines have ignition counts and ullage requirements. Validate the clamp release TWR and timeout in simulation before flying for career - the defaults are tuned for kerolox sounding rockets, not every engine.
