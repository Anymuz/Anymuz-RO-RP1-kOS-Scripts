# alarmSounds.ks

Path: `0:/lib/sounds/alarmSounds.ks`

## Purpose
Note tables for looping alarms. Each function returns a list of notes that the alarm voice plays in a loop until stopped.

## Functions
- `getDetonationAlarm()` - alternating high/low pattern with a long low closer. Used by `playDetonationAlarm`.
- `getEngineFailureAlarm()` - fast double-beep with a low closer. Used by `playEngineFailureAlarm`.

## Notes
Loaded by `loadAlarms()` in `lib/audio.ks`. The voice is a SAWTOOTH wave on `GETVOICE(2)` with `LOOP = TRUE`. Stopped by the alarm-stop key listener or `stopAlarmSound`.
