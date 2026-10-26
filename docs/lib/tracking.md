# tracking.ks

Path: `0:/lib/tracking.ks`

## Purpose
Background flight monitoring. One trigger updates running maxima in `flightData`. Another watches tagged engines and reports ignition failure, complete failure, flameout (with or without fuel), and thrust loss, with audible alarms.

## Imports
- `0:/lib/resources.ks` (`getResourcePercent`)

## Functions
- `trackFlightStats()` - arms a `WHEN TRUE THEN` loop that updates `maxVelocity`, `maxVelocityAlt`, `apogeeAlt`, `apogeeVelocity`, `maxApoapsis`, `maxApoapsisAlt`, and sets `descentCaptured` once vertical speed goes negative.
- `monitorEngines(engineTag, remainingFuelPercentage, fuelTank, spoolupTime)` - arms a `WHEN TRUE THEN` loop that walks every tagged engine and logs the first occurrence of:
  - ignition failure (thrust never appeared with fuel available)
  - complete failure (was running, now zero with fuel available)
  - flameout (separated by fuel-available vs fuel-depleted)
  - thrust loss (below 85% of max with fuel and past the spoolup grace window)
  Plays the engine-failure alarm on hard failures. Logs a single `Main engine offline.` once any of the above fires. Fuel presence is a live whole-tank fill percentage via `getResourcePercent("", fuelTank)`, so no resource names are passed in.

## Notes
`remainingFuelPercentage` is a whole-percentage number (e.g. `5.88`, not `0.0588`) - the expected tank fill % remaining at natural engine cutoff, so a shutdown from normal fuel depletion isn't flagged as a malfunction. Compared directly against the live `getResourcePercent("", fuelTank)` reading each tick, no starting-fuel snapshot needed. `spoolupTime` is clamped to a minimum 0.7s grace before thrust-loss reports trigger to avoid false positives during ignition.
