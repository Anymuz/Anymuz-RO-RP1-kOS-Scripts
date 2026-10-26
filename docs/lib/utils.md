# utils.ks

Path: `0:/lib/utils.ks`

## Purpose
Small shared helpers used by every program and ship script. Resource reads live in `0:/lib/resources.ks`, not here.

## Functions
- `countBoosterIgnitions(boosterTag)` - number of tagged boosters currently producing thrust or signalling ignition.
- `startupMessage(electricChargeLevel)` - logs the on-internal-power alert and the startup charge reading.
- `outputFlightData()` - prints and logs a formatted summary of `flightData` (apogee, max velocity, predicted apoapsis, phase, flight time, current altitude/vertical speed). Called at end-of-flight or after a destruct arm.
- `initalizeProgram()` - reads starting power from `shipResources["ElectricCharge"]["amount"]` (guarded with `HASKEY`), aborts if zero, otherwise arms the alarm-stop key and prints the startup message. Do not call directly - the family's `programs/<family>.ks` script calls it.
- `greatCircleDistance(fromGeo, toGeo)` / `downrangeDistance(launchGeo)` - surface distance helpers used by flight data output and GUI panels.
- `metersIntoMiles(meters)`, `velocityMph(vel)`, `velocityKmh(vel)` - unit conversions for the GUI.

## Notes
Pure helpers. Safe to call any time after `lib/logging.ks` is loaded and `flightData` exists. `initalizeProgram` additionally requires `lib/resources.ks` loaded and `shipResources` populated.
