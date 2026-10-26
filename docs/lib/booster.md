# booster.ks

Path: `0:/lib/booster.ks`

## Purpose
Booster-stage ignition check and main-engine handoff. Watches booster fuel and runs two triggers depending on the launch flow chosen by the ship: ignites the main engine just before booster burnout (sequential flow), then separates spent boosters once fuel is below a safe-separation threshold.

## Imports
- `0:/lib/resources.ks` (`getResourcePercent`)
- `0:/lib/parts.ks` (`resolveTaggedActionModules`, `igniteResolvedModules`)

## Functions
- `armBoosterSeperation(boosterTag, separatorTag, mainEngineTag, preigniteMainThreshold, boosterShutdownThreshold)` - reads the current `flightData["phase"]`, then arms a `WHEN TRUE THEN` loop:
  - If the launch function already set phase to `main` (simultaneous ignition - main engine + boosters lit together), this function leaves the phase alone and **skips Trigger A**. Only Trigger B (separation) runs.
  - Otherwise it sets phase to `booster` and runs the legacy sequential flow:
    1. **Trigger A** ignites the main engine, by its part tag (`mainEngineTag`, via `resolveTaggedActionModules`/`igniteResolvedModules`), when booster fill % (`getResourcePercent("", boosterTag)`, every resource on the tagged booster parts) falls to/below `preigniteMainThreshold`.
    2. **Trigger B** decouples the boosters, by the separator part's own tag (`separatorTag`, distinct from `boosterTag`, resolved once up front via `resolveTaggedActionModules` then fired together with `igniteResolvedModules` so every separator pops the same tick), once that same fill % falls to/below `boosterShutdownThreshold`.
  - Partial booster ignition (some boosters lit, others not) calls `selfDestruct` immediately.

## Notes
`preigniteMainThreshold` and `boosterShutdownThreshold` are fill percentages (0-100, e.g. `40` and `3.9`), not fractions or absolute amounts - tune them against the booster's own fuel percentage on the test stand. Booster fuel is discovered by tag, not by resource name, so this works regardless of what propellant the boosters use. For simultaneous-ignition vehicles only the separation threshold matters; `preigniteMainThreshold` is unused.

