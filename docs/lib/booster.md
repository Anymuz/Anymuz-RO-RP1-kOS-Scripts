# booster.ks

Path: `0:/lib/booster.ks`

## Purpose
Booster-stage ignition check and main-engine handoff. Watches booster fuel and runs two triggers depending on the launch flow chosen by the ship: ignites the main engine just before booster burnout (sequential flow), then separates spent boosters once fuel is below a safe-separation threshold.

## Functions
- `armBoosterSeperation(boosterTag, boosterFuelName, preigniteMainFuel, boosterShutdownFuel)` - reads the current `flightData["phase"]`, then arms a `WHEN TRUE THEN` loop:
  - If the launch function already set phase to `main` (simultaneous ignition - main engine + boosters lit together), this function leaves the phase alone and **skips Trigger A**. Only Trigger B (separation) runs.
  - Otherwise it sets phase to `booster` and runs the legacy sequential flow:
    1. **Trigger A** stages the main engine when booster fuel falls below `preigniteMainFuel`.
    2. **Trigger B** stages booster separation once fuel falls below `1.5 * boosterShutdownFuel` (avoids dry-separation instability).
  - Partial booster ignition (some boosters lit, others not) calls `selfDestruct` immediately.

## Notes
Tune `preigniteMainFuel` so the main engine ignites roughly 1-2 seconds before the booster burns out (sequential flow only). Tune `boosterShutdownFuel` to whatever the boosters actually shut down at on the test stand. Both are absolute amounts, not percentages. For simultaneous-ignition vehicles only the separation threshold matters; `preigniteMainFuel` is unused.
