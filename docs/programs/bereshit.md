# bereshit.ks

Path: `0:/programs/bereshit.ks`

## Purpose
Family program for the Bereshit class of sounding rockets. Imports the libraries the family uses, declares family-wide globals (engine tag, fuel tank, resources, thresholds), wires up the per-ship log file, and provides Bereshit-specific helpers.

## Imports
- `0:/lib/launch.ks`
- `0:/lib/tracking.ks`
- `0:/lib/booster.ks`
- `0:/lib/detonation.ks`
- `0:/lib/downrange.ks`

## Globals declared
- Part tags: `boosterType`, `mainEngine`, `fuelTank`, `avionicsCore`.
- Resources: `boosterFuel`, `propellant`, `oxidizer`, `pressurizer`, `ignitiant`.
- Starting levels: `boosterFuelLevel`, `propellantLevel`, `oxidizerLevel`, `pressurizerLevel`, `ignitiantLevel`, `electricChargeLevel` (all sums via `sumPartResource`).
- Thresholds: `boosterPreigniteMainThreshold`, `boosterShutdownThreshold`, `fuelThreshold`, `mainEngineStartThreshold`.
- `logConfig["logFile"]` is repointed to `archive:/logs/<shipName>_flightlog.txt`.

## Functions
- `activateTelemetry(seriesVariant)` - enables the right action groups for telemetry and sensors per variant. R1 toggles AG1/AG2/AG3; R2 is currently a placeholder.
- `startupMessage(electricChargeLevel)` - logs the EC-on-ship-power banner.
- `initalizeBereshit(electricChargeLevel, seriesVariant)` - guard rails for ship class and EC, opens a new log session, switches log clock to ship time, arms the alarm-stop key, then runs telemetry and the startup banner.

## Notes
Per-ship scripts may override any of the family globals with `SET` after the import. Variants that need different engines or resources should override before calling `initalizeBereshit`.
