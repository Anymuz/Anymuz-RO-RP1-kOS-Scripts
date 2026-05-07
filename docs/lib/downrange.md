# downrange.ks

Path: `0:/lib/downrange.ks`

## Purpose
Downrange ascent guidance. Two-phase pitch program: an immediate kick from vertical to a kick pitch, then a shaped curve from kick pitch to a final powered pitch. After the configured guidance-end altitude the script either holds surface prograde or unlocks steering, then releases steering at apogee.

## Functions
- `clampValue(value, minValue, maxValue)` - generic numeric clamp. Reused across the project.
- `calculateDownrangePitch(turnStartAlt, kickEndAlt, turnEndAlt, kickPitch, finalPitch, turnShape)` - pure. Returns the target pitch for the current `ALTITUDE`. Validates the ordering of the altitude bands and falls back to 90 (vertical) on bad input.
- `logDownrangeProfile(...)` - dumps the configured profile to the log so the flight record contains the parameters used.
- `armDownrangeGuidance(launchAzimuth, turnStartAlt, kickEndAlt, turnEndAlt, kickPitch, finalPitch, turnShape, guidanceEndAlt, lockProgradeAfterGuidance)` - arms the guidance `WHEN TRUE THEN` loop. Locks steering to `HEADING(azimuth, calculatedPitch)`, throttles a 5-second telemetry log, switches to surface prograde at `guidanceEndAlt` (or unlocks), and unlocks steering when apogee is reached.

## Notes
`turnShape < 1` makes the early turn more aggressive. `turnShape > 1` holds the steeper attitude longer. RSS scale: do not port stock-tuned numbers, the real-scale planet changes everything.
