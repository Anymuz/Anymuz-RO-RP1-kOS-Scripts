# testAudio.ks

Path: `0:/system/testAudio.ks`

## Purpose
Standalone audio test harness. Initialises the logger and audio driver, then plays an indefinite engine-failure alarm so you can verify the alarm-stop key works. Runs forever until the stop key is pressed or the script is interrupted.

## Imports
- `0:/lib/logging.ks`
- `0:/lib/audio.ks`

## Functions
None.

## Notes
Boot it via `boot/audioTests.ks`. Default stop key is `#`. If the alarm does not stop on key press, hit `Ctrl+C` in the terminal.
