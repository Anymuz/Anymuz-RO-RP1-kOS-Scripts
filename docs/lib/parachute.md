# parachute.ks

Path: `0:/lib/parachute.ks`

## Purpose
Parachute recovery. The descent-side alternative to `lib/detonation.ks`: instead of destroying the vehicle, it jettisons the chute fairing and deploys parachutes at a target altitude, and dumps flight data at apogee and at touchdown.

## Imports
- `0:/lib/logging.ks` (for `logMessage` / `outputFlightData`)

## Functions
- `jettisonChuteFairing(fairingTag)` - jettisons every part tagged `fairingTag` via the `ProceduralFairingDecoupler` `jettison fairing` action, falling back to the stock `ModuleProceduralFairing` action. Logs how many parts were jettisoned.
- `armParachute(chuteTag, deployAlt, useRadarAlt, fairingTag)` - arms the descent triggers:
  - On the first sustained negative vertical speed, sets phase to `descent`, marks `descentCaptured`, and dumps flight data (mirrors `armAltitudeDetonation`).
  - Once descending below `deployAlt` (radar or sea-level altitude per `useRadarAlt`), waits one second then deploys every `RealChuteModule` part tagged `chuteTag`, sets phase to `chute`, and arms a touchdown trigger.
  - On `LANDED` / `SPLASHED`, sets phase to `landed` and dumps the final flight data.

## Notes
Deploys via `RealChuteModule:DOACTION("deploy chute")`; for stock parachutes swap the module/action. The fairing jettison line inside `armParachute` is currently commented out (the chute deploys through the fairing) - uncomment `jettisonChuteFairing` if your design needs the fairing popped first. Validate `deployAlt` against safe RealChute deployment speeds in simulation. Defaults: `chuteTag = "chute"`, `deployAlt = 15000`, `useRadarAlt = TRUE`, `fairingTag = "CHUTE-CASE"`.
