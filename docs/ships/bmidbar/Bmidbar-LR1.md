# Bmidbar-LR1.ks

Path: `0:/ships/bmidbar/Bmidbar-LR1.ks`

## Purpose
Entry script for the Bmidbar LR1. Clamp-held liquid ignition, no booster stage, downrange guidance armed after liftoff. Uses the kick-pitch form of the downrange profile.

## Imports
- `0:/programs/bmidbar.ks`

## Locals declared
- Mission: `countdownTime`, `destructAlt`, `useRadarAlt`.
- Clamp-held launch: `clampReleaseTWR`, `maxClampWait`, `requirePropellantDrain`.
- Downrange guidance: `launchAzimuth`, `turnStartAlt`, `kickEndAlt`, `turnEndAlt`, `kickPitch`, `finalPitch`, `turnShape`, `guidanceEndAlt`, `lockProgradeAfterGuidance`.

## Family overrides
None at file scope. Engines, fuel tanks, and resources come from `programs/bmidbar.ks`.

## Sequence
1. `initalizeBmidbar(electricChargeLevel, shipVariant)`.
2. Mission banner via `logMessage`.
3. `initializeLaunch()` then `countdownLaunch(countdownTime)`.
4. `launchShipClampTWR(...)` - aborts the mission via `WAIT UNTIL FALSE` if it returns FALSE.
5. `trackFlightStats()`, `monitorEngines(...)`.
6. `armDownrangeGuidance(...)` using the kick-pitch parameters.
7. `armAltitudeDetonation(destructAlt, useRadarAlt)`.
8. `WAIT UNTIL FALSE`.

## Notes
The file contains commented-out alternate guidance profiles from earlier flights. Treat these as a tuning history; the active profile is the uncommented one.
