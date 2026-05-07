# detonation.ks

Path: `0:/lib/detonation.ks`

## Purpose
Safety destruct. Arms after the vehicle starts descending, then triggers when altitude drops below a threshold. Plays the detonation alarm and trips `ABORT` (which is wired to the flight termination action group on the craft).

## Functions
- `armAltitudeDetonation(destructAlt, useRadarAlt)` - on the first negative vertical-speed reading sets phase to `descent`, dumps flight data, and arms either `WHEN ALT:RADAR < destructAlt` or `WHEN ALTITUDE < destructAlt`.
- `altitudeDetonation()` - logs and plays the 3-second detonation alarm, then sets `ABORT ON`.
- `selfDestruct(reason, fuzeTime)` - immediate abort path used by other libraries (e.g. partial booster ignition). Plays the detonation alarm for `fuzeTime` seconds, then `ABORT ON`.

## Notes
The vehicle must have its flight termination action group on `AG10` (the default `ABORT` group) for this to do anything meaningful. Sea-level altitude is the default; radar altitude is more accurate but noisier on rough terrain.
