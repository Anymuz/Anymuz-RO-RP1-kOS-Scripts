# utils.ks

Path: `0:/lib/utils.ks`

## Purpose
Small shared helpers used by every program and ship script.

## Functions
- `sumPartResource(partTag, resourceName)` - total amount of `resourceName` across all parts tagged `partTag`.
- `countBoosterIgnitions(boosterTag)` - number of tagged boosters currently producing thrust or signalling ignition.
- `outputFlightData()` - prints and logs a formatted summary of `flightData` (apogee, max velocity, predicted apoapsis, phase, flight time, current altitude/vertical speed). Called at end-of-flight or after a destruct arm.

## Notes
Pure helpers. Safe to call any time after `lib/logging.ks` is loaded and `flightData` exists.
