# main.ks

Path: `0:/system/main.ks`

## Purpose
First real script after boot. Initialises logging, derives ship identity from `SHIP:NAME`, declares the global `flightData` lexicon, loads the shared utility and audio libraries, then hands off to `loadShip.ks` to dispatch the per-ship script.

## Imports
- `0:/lib/logging.ks`
- `0:/lib/utils.ks`
- `0:/lib/audio.ks`
- `0:/system/loadShip.ks` (run via `RUNPATH`)

## Globals declared
- `shipName` - copy of `SHIP:NAME`.
- `shipSeries` - prefix before the first `-` in the name.
- `shipVariant` - suffix after the first `-` (or `"N/A"` if no `-`).
- `flightData` - lexicon used by tracking, guidance, and post-flight summaries. Keys: `phase`, `maxVelocity`, `maxVelocityAlt`, `apogeeAlt`, `apogeeVelocity`, `descentCaptured`, `maxApoapsis`, `maxApoapsisAlt`.

## Functions
None. Setup runs at top level.

## Notes
Anything that needs to exist before ship code runs goes here. Keep it short, the storage budget is real.
