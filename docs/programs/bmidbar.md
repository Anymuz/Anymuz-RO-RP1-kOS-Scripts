# bmidbar.ks

Path: `0:/programs/bmidbar.ks`

## Purpose
Family program for the Bmidbar class. Same role as the Bereshit program but with Bmidbar-specific defaults (different engine and resources, no booster stage by default). Imports the same library set and configures logging.

## Imports
- `0:/lib/launch.ks`
- `0:/lib/tracking.ks`
- `0:/lib/booster.ks`
- `0:/lib/detonation.ks`
- `0:/lib/downrange.ks`

## Globals declared
- Part tags: `mainEngine`, `avionicsCore`, `fuelTank`. Booster tags are commented out (no booster stage).
- Resources: `propellant`, `oxidizer`, `oxidizer2`. Booster fuel and ignitiant commented out.
- Starting levels: `propellantLevel`, `oxidizerLevel`, `electricChargeLevel`.
- Thresholds: `fuelThreshold`, `mainEngineStartThreshold`.
- `logConfig["logFile"]` repointed to `archive:/logs/<shipName>_flightlog.txt`.

## Functions
- `initalizeBmidbar(electricChargeLevel, seriesVariant)` - guard rails for ship class and EC, opens a new log session, switches log clock to ship time, arms the alarm-stop key. Telemetry hookup is currently commented out pending sensor design.

## Notes
Bmidbar variants currently fly without a booster. If a future variant adds one, define `boosterType`, `boosterFuel`, and the related thresholds either here or in the ship script before arming `armBoosterSeperation`.
