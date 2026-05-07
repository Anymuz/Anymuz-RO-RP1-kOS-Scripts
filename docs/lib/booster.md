# booster.ks

Path: `0:/lib/booster.ks`

## Purpose
Booster-stage ignition check and main-engine handoff for vehicles that ignite a strap-on or first-stage booster before the main engine. Watches booster fuel and stages the main engine when fuel drops below a configured threshold, then separates the booster.

## Functions
- `armBoosterSeperation(boosterTag, boosterFuelName, preigniteMainFuel, boosterShutdownFuel)` - sets phase to `booster`, checks for partial booster ignition (any partial failure triggers `selfDestruct`), then arms a `WHEN TRUE THEN` loop that:
  1. Stages the main engine when booster fuel falls below `preigniteMainFuel`.
  2. Stages booster separation when fuel falls below `2 * boosterShutdownFuel` (avoids dry separation jolt).

## Notes
Tune `preigniteMainFuel` so the main engine ignites roughly 1-2 seconds before the booster burns out. Tune `boosterShutdownFuel` to whatever the boosters actually shut down at on the test stand. Both are absolute amounts, not percentages.
