# failureInfo.ks

Path: `0:/system/failureInfo.ks`

## Purpose
Run by `loadShip.ks` when no per-ship script can be resolved from `SHIP:NAME`. Prints the naming convention and the resolved path that was missing, so the operator can fix the vessel name or add the script.

## Imports
None at runtime. Relies on `lib/logging.ks` already being loaded by `system/main.ks` (uses `skipLine`).

## Functions
None. Sequential `PRINT` lines only.

## Notes
Read-only diagnostic. Does not affect flight state.
