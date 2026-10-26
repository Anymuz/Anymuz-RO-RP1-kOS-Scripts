# panels/audioPanel.ks

Path: `0:/lib/gui/panels/audioPanel.ks`

## Purpose
GUI panel of safe buttons that exercise the audio driver (`lib/audio.ks`).

## Imports
- `0:/lib/gui/guiCore.ks`
- Calls `testAlertAudio`, `testLaunchAudio`, `testAlarms`, `fullAudioTest`, `playAlertSound`, `playWarningSound`, `playCriticalSound`, `stopAlarmSound` (all `lib/audio.ks`).

## Globals declared
- None.

## Functions
- `buildAudioPanel(parentBox)` - adds an AUDIO TEST section: test rows (Alerts / Launch / Alarms / Full), tone buttons (Alert / Warn / Critical), and a **Silence Alarm** button.

## Notes
All actions are reversible sound playback. The sounds need `setupAudio()` to have
run; otherwise the audio functions just log that the driver is not initialised.
