# Bereshit-R2.ks

Path: `0:/ships/bereshit/Bereshit-R2.ks`

## Purpose
Entry script for the Bereshit R2 variant. Clamp-held liquid ignition, no booster stage, downrange guidance armed after liftoff. Overrides the family defaults for engine, fuel tank, and resources because R2 uses a different propellant combo.

## Imports
- `0:/programs/bereshit.ks`

## Locals declared
- Mission config: `countdownTime`, `destructAlt`, `useRadarAlt`.
- Resource levels: `boosterFuelLevel`, `propellantLevel`, `oxidizerLevel`, `pressurizerLevel`, `ignitiantLevel`, `electricChargeLevel`.
- Engine monitoring: `fuelThreshold`, `mainEngineStartThreshold`.
- Clamp-held launch: `clampReleaseTWR`, `maxClampWait`, `requirePropellantDrain`.
- Downrange guidance: `launchAzimuth`, `turnStartAlt`, `turnEndAlt`, `finalPitch`, `turnShape`, `earlyControlAlt`, `earlyMinPitch`, `guidanceEndAlt`, `lockProgradeAfterGuidance`.

## Family overrides
- `boosterType`, `mainEngine`, `fuelTank`.
- `boosterFuel`, `propellant`, `oxidizer`, `pressurizer`, `ignitiant`.

## Sequence
1. `initalizeBereshit(electricChargeLevel, shipVariant)`.
2. Mission banner via `logMessage`.
3. `initializeLaunch()` then `countdownLaunch(countdownTime)`.
4. `launchShipClampTWR(...)` - aborts the mission via `WAIT UNTIL FALSE` if it returns FALSE.
5. `trackFlightStats()`, `monitorEngines(...)`.
6. `armDownrangeGuidance(...)`.
7. `armAltitudeDetonation(destructAlt, useRadarAlt)`.
8. `WAIT UNTIL FALSE`.

## Notes
The downrange parameter signature here is the older form (`turnStartAlt, turnEndAlt, finalPitch, turnShape, earlyControlAlt, earlyMinPitch, ...`). If `lib/downrange.ks` migrates fully to the kick-pitch form, update this script to match.
