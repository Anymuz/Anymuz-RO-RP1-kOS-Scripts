# loadShip.ks

Path: `0:/system/loadShip.ks`

## Purpose
Picks the right per-ship script based on `SHIP:NAME` and runs it. Names containing `-` are treated as `<family>-<variant>` and resolved to `0:/ships/<family>/<SHIP:NAME>.ks`. Names without `-` resolve to `0:/ships/<SHIP:NAME>.ks`. If the resolved file does not exist it falls through to `system/failureInfo.ks`.

## Imports
- Calls `setupAudio()` (from `lib/audio.ks`, already loaded by `main.ks`).
- `RUNPATH`s the resolved ship file or `system/failureInfo.ks`.

## Functions
None.

## Notes
The vessel name in-game must match the script file name exactly, including case. Add a new script under `ships/<family>/` and the dispatch picks it up automatically.
