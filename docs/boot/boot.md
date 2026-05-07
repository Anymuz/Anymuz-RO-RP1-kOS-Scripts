# boot.ks

Path: `0:/boot/boot.ks`

## Purpose
Default kOS boot file. Set this in the VAB/SPH on the kOS part. Waits for the vessel to unpack, opens the terminal, then runs `system/main.ks`. Kept tiny so it fits in the tight boot-file storage budget.

## Imports
None.

## Functions
None. Top-level commands only.

## Notes
If you need a boot file that runs something other than `main.ks` (e.g. an audio test rig), copy this file under a new name and change the final `RUNPATH`.
