# audio.ks

Path: `0:/lib/audio.ks`

## Purpose
Audio driver. Wraps three kOS voices for one-shot tones (launch/countdown), short alerts (critical/warning/alert), and looping alarms (detonation, engine failure). Provides a key-listener that stops alarms on a configurable key. Note tables come from `lib/sounds/*.ks`.

## Globals declared
- `audioInitialized`, `launchAudio`, `alertAudio`, `alarmSound` - voice handles and init flag.
- `alarmState` - lexicon: `active`, `name`, `stopTime`.
- `alarmStopKey`, `alarmStopKeyArmed` - key listener state.

## Functions
- `setupAudio(stopAlarmKey, testAudio)` - load all three voices and arm the stop-key listener. Optional self-test.
- `bypassAudioSetup()` - mark audio as initialised without loading voices. Only for failure screens that just need the API to no-op.
- `loadLaunchAudio()`, `loadAlertAudio()`, `loadAlarms()` - voice setup helpers used by `setupAudio`.
- `checkAudioInitialized()` - returns FALSE and logs an error if `setupAudio` was never called.
- `armAlarmKeyStop(keyName)` - install the `WHEN TERMINAL:INPUT:HASCHAR` listener that stops alarms on the configured key.
- `playCountdownSound()`, `playLaunchSound()` - one-shot launch tones.
- `playCriticalSound()`, `playWarningSound()`, `playAlertSound()` - short alert tones, used by `logMessage` when `playSound = TRUE`.
- `playDetonationAlarm(duration)`, `playEngineFailureAlarm(duration)` - looping alarms. `duration = 0` means play until stopped.
- `stopAlarmSound(manualStop)` - stop whichever alarm is active.
- `stopAlarmAfter(seconds)` - schedules a stop via a `WHEN` trigger.
- `logAlarmStarted(name, duration)`, `logAlarmStopped(manualStop)` - internal alarm bookkeeping and logging.
- `testAlertAudio()`, `testLaunchAudio()`, `testAlarms(duration)`, `fullAudioTest(alarmDuration)` - test harnesses.

## Notes
Default alarm stop key is `#`. Override via the `setupAudio` parameter or `armAlarmKeyStop`.
