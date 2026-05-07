# launchSounds.ks

Path: `0:/lib/sounds/launchSounds.ks`

## Purpose
Note table for the launch voice. Defines short tones for the countdown beep and the liftoff tone.

## Functions
- `getCountdownNote()` - returns the `NOTE` used per countdown tick.
- `getLaunchNote()` - returns the `NOTE` played at liftoff.

## Notes
Loaded by `loadLaunchAudio()` in `lib/audio.ks`. The voice is a SINE wave on `GETVOICE(0)`.
