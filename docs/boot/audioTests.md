# audioTests.ks

Path: `0:/boot/audioTests.ks`

## Purpose
Alternate boot file for testing the audio driver without flying. Set this in the VAB/SPH if you only want to verify sounds. Waits for unpack, opens the terminal, then runs `system/testAudio.ks`.

## Imports
None.

## Functions
None.

## Notes
Not for flight. Switch back to `boot/boot.ks` before launching anything you care about.
