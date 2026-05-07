# Bereshit-R1.ks

Path: `0:/ships/bereshit/Bereshit-R1.ks`

## Purpose
Entry script for the Bereshit R1 sounding rocket. Booster-first design, so it uses the simple `launchShip` ignition path and arms `armBoosterSeperation` for booster-to-main handoff. No downrange guidance configured for this variant.

## Imports
- `0:/programs/bereshit.ks`

## Locals declared
- `countdownTime`, `destructAlt`, `useRadarAlt`.
- Other thresholds and resource levels are inherited from `programs/bereshit.ks`.

## Sequence
1. `initalizeBereshit(electricChargeLevel, shipVariant)` - EC and class checks, telemetry, banner.
2. `initializeLaunch()` then `countdownLaunch(countdownTime)`.
3. `launchShip()` - simple stage-and-go ignition.
4. `armBoosterSeperation(...)` with the family thresholds scaled by `boosterFuelLevel`.
5. `trackFlightStats()`, `monitorEngines(...)`.
6. `armAltitudeDetonation(destructAlt, useRadarAlt)`.
7. `WAIT UNTIL FALSE` to keep the program alive.

## Notes
Tunings are R1-specific and have been validated in the in-game simulation. Re-validate after any engine, fuel, or part swap.
