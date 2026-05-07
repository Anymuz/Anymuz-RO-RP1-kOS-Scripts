# alertSounds.ks

Path: `0:/lib/sounds/alertSounds.ks`

## Purpose
Note table for the alert voice. Defines short tones for `critical`, `warning`, and `alert` log severities.

## Functions
- `getCriticalNote()` - low-frequency tone for `critical` events.
- `getWarningNote()` - mid-frequency tone for `warning` events.
- `getAlertNote()` - higher-frequency tone for `alert` events.

## Notes
Loaded by `loadAlertAudio()` in `lib/audio.ks`. The voice is a SQUARE wave on `GETVOICE(1)`. Triggered automatically by `logMessage` when `playSound = TRUE`.
