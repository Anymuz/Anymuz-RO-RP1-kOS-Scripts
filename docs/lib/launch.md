# launch.ks

Path: `0:/lib/launch.ks`

## Purpose
Launch sequencing. Two ignition styles are supported: a simultaneous main-engine + booster ignition for cluster-style first stages, and a clamp-held liquid ignition that releases the clamp only after a stable TWR is confirmed. Also provides the standby prompt and the countdown.

## Functions

### Sequencing
- `initializeLaunch()` - "press any key" standby and audible launch-sequence-commencing alert.
- `countdownLaunch(seconds)` - on-screen countdown with countdown tone every second.

### Simple launch
- `launchShip()` - simultaneous main-engine + booster ignition. Sets `flightData["phase"]` to `prelaunch`, locks throttle and steering, calls `STAGE` (which must light the main engine and boosters together), plays launch sound, then sets `flightData["phase"]` directly to `main` so `armBoosterSeperation` skips its own main-engine ignition trigger. Better stability and momentum buildup than the prior booster-only ignition. The legacy booster-first variant remains commented out at the top of the function for vehicles that need it back.

### Clamp-held tagged-engine helpers (pure)
- `getTaggedEngineThrust(engineTag)` - sum of current thrust across tagged engines.
- `getTaggedEngineMaxThrust(engineTag)` - sum of max thrust across tagged engines.
- `getTaggedEngineTWR(engineTag)` - current thrust / weight using `CONSTANT:G0`.
- `taggedEnginesHaveFlameout(engineTag)` - TRUE if any tagged engine reports flameout.
- `taggedEnginesHaveIgnitionSignal(engineTag)` - TRUE if any tagged engine signals ignition.
- `countTaggedEngines(engineTag)` - number of parts with the tag.

### Clamp-held ignition flow
- `checkClampHeldEngineHealth(engineTag, minimumThrust)` - lightweight prelaunch sanity check (engine present, no flameout). Returns FALSE on hard failures.
- `waitForClampReleaseReadiness(engineTag, fuelTankTag, propellant, oxidizer, releaseTWR, maxClampWait, stableHoldTime, maxTWRDrop, requirePropellantDrain, resourceCheckDelay)` - polls TWR and resource drain after ignition. Aborts on flameout, thrust decay, missing propellant drain, or timeout. Returns TRUE when stable TWR is held for `stableHoldTime`.
- `launchShipClampTWR(engineTag, fuelTankTag, propellant, oxidizer, releaseTWR, maxClampWait, launchAzimuth, requirePropellantDrain)` - the full clamp-held sequence: ignition stage, readiness wait, clamp release. Returns FALSE on abort so the ship script can skip post-launch arming.

## Notes
RO engines have ignition counts and ullage requirements. Validate the clamp release TWR and timeout in simulation before flying for career - the defaults are tuned for kerolox sounding rockets, not every engine.
