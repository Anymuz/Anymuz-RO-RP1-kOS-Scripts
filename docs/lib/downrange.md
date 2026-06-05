# downrange.ks

Path: `0:/lib/downrange.ks`

## Purpose
Downrange ascent guidance. Two-phase pitch program: an immediate kick from vertical to a kick pitch, then a shaped curve from kick pitch to a final powered pitch. After the configured guidance-end altitude the script either holds surface prograde or unlocks steering, then releases steering at apogee.

## Functions
- `clampValue(value, minValue, maxValue)` - generic numeric clamp. Reused across the project.
- `calculateDownrangePitch(turnStartAlt, kickEndAlt, turnEndAlt, kickPitch, finalPitch, turnShape)` - pure. Returns the target pitch for the current `ALTITUDE`. Validates the ordering of the altitude bands and falls back to 90 (vertical) on bad input.
- `logDownrangeProfile(...)` - dumps the configured profile to the log so the flight record contains the parameters used.
- `armDownrangeGuidance(launchAzimuth, turnStartAlt, kickEndAlt, turnEndAlt, kickPitch, finalPitch, turnShape, guidanceEndAlt, lockProgradeAfterGuidance)` - arms the guidance `WHEN TRUE THEN` loop. Locks steering to `HEADING(azimuth, calculatedPitch)`, throttles a 5-second telemetry log, switches to surface prograde at `guidanceEndAlt` (or unlocks), and unlocks steering when apogee is reached.

## Pitch program

The guidance runs in three altitude bands, all measured as sea-level `ALTITUDE`:

```
       90 deg                                                      (vertical)
        |---------|
        |          \
        |            \  Phase 1: linear kick
        |              \
        | kickPitch ---- *  <-- kickEndAlt
        |                 \
        |                  \  Phase 2: shaped curve (turnShape)
        |                    \
        |                      *---- finalPitch  <-- turnEndAlt
        |                       |
        |                       |  Phase 3: hold finalPitch heading
        |                       |
        |                       *  <-- guidanceEndAlt -> srfprograde or unlock
        |
       0 deg                                                       (horizontal)
   turnStartAlt           kickEndAlt    turnEndAlt   guidanceEndAlt
```

| Band | Altitude range | Pitch behavior |
| --- | --- | --- |
| Pre-turn | `ALTITUDE < turnStartAlt` | Hold 90 (vertical). Useful if you want a clean vertical climb before any turning. Set `turnStartAlt = 0` to start turning the moment guidance arms. |
| Phase 1 (kick) | `turnStartAlt <= ALTITUDE < kickEndAlt` | Linear interpolation from 90 down to `kickPitch`. This is the deliberate, visible kick that establishes downrange velocity early instead of the lazy gravity turn most stock-tuned tutorials use. |
| Phase 2 (curve) | `kickEndAlt <= ALTITUDE < turnEndAlt` | `targetPitch = kickPitch - (kickPitch - finalPitch) * progress^turnShape`, where `progress` is the normalised altitude across the band. Result is clamped to `[finalPitch, 90]`. |
| Phase 3 (hold) | `turnEndAlt <= ALTITUDE < guidanceEndAlt` | Heading is held at `(launchAzimuth, finalPitch)` (clamp from Phase 2 keeps it there). |
| Post-guidance | `ALTITUDE >= guidanceEndAlt` | If `lockProgradeAfterGuidance = TRUE`, lock to `SHIP:SRFPROGRADE` until apogee, then unlock. If `FALSE`, unlock steering immediately. |

### Parameters at a glance

| Parameter | Default | Meaning |
| --- | --- | --- |
| `launchAzimuth` | 90 | Compass heading the steering lock points to. 90 = due east (max benefit from Earth's rotation), 0 = north, 180 = south, etc. Use it for polar / retrograde / dogleg launches. |
| `turnStartAlt` | 0 | Altitude (m, ASL) at which the kick begins. |
| `kickEndAlt` | 300 | Altitude at which the kick reaches `kickPitch`. The smaller the gap `kickEndAlt - turnStartAlt`, the sharper the kick. |
| `turnEndAlt` | 15000 | Altitude at which the curve reaches `finalPitch`. |
| `kickPitch` | 65 | Pitch at the end of Phase 1. Lower = more aggressive initial kick. |
| `finalPitch` | 30 | Pitch at the end of Phase 2 and held through Phase 3. Lower = flatter trajectory / more downrange. |
| `turnShape` | 0.6 | Shape exponent of the Phase 2 curve. **< 1 turns aggressively early then flattens; > 1 holds the steeper attitude longer then turns late; = 1 is linear.** |
| `guidanceEndAlt` | 90000 | Altitude at which active pitch steering stops. |
| `lockProgradeAfterGuidance` | TRUE | After `guidanceEndAlt`, hold surface prograde until apogee (good for atmospheric / sounding flights). Set FALSE for orbital insertions where another script (e.g. circularisation) takes over steering. |

## Tuning for different missions

The defaults are tuned for a small kerolox sounding rocket on RSS. Change them per vehicle. A few starting points:

### Vertical sounding rocket (no downrange)
Don't arm `armDownrangeGuidance` at all. Let the ship hold UP via `LOCK STEERING TO UP.` from `launchShip` and skip the call. This is what `Bereshit-R1` does on the Anymuz-Personal branch.

### Downrange sounding rocket (small kerolox, RSS)
```
launchAzimuth                 = 90      // due east
turnStartAlt                  = 0
kickEndAlt                    = 300
turnEndAlt                    = 15000
kickPitch                     = 65
finalPitch                    = 30
turnShape                     = 0.6
guidanceEndAlt                = 90000
lockProgradeAfterGuidance     = TRUE
```
Aggressive early kick keeps gravity losses low on a low-TWR vehicle; prograde hold afterwards lets the rocket coast to apogee on its own.

### High-apogee suborbital
```
kickPitch                     = 75      // gentler kick
finalPitch                    = 45      // steeper finish, more vertical
turnEndAlt                    = 30000
turnShape                     = 1.0     // linear
guidanceEndAlt                = 120000
lockProgradeAfterGuidance     = TRUE
```
Higher `finalPitch` keeps more vertical component for max apogee; raise `turnEndAlt` so the curve completes higher up.

### Orbital insertion (small first stage)
```
kickPitch                     = 70
finalPitch                    = 0       // horizontal at end of pitch program
turnEndAlt                    = 60000
turnShape                     = 0.5     // earlier aggressive turn
guidanceEndAlt                = 70000   // hand off above the bulk of the atmosphere
lockProgradeAfterGuidance     = FALSE   // let the circularisation script take over
```
Drive `finalPitch` to 0 so the vehicle is roughly horizontal by the end of the pitch program, then hand off to a separate circularisation routine.

### High-thrust / heavy-TWR vehicles
Raise `turnShape` (e.g. 1.2-1.5) to delay the sharper part of the turn - high TWR means you build vertical speed quickly and don't want to dump it horizontally too early. Reduce `kickPitch` only slightly (e.g. 75) so you don't pitch over before clearing aerodynamic risk.

### Polar or retrograde
Just set `launchAzimuth` (0 = north, 180 = south, 270 = west / retrograde). The pitch program is independent of azimuth. Note: retrograde launches lose ~930 m/s on Earth and will need a much bigger booster.

### Dogleg
Currently the function takes a single fixed `launchAzimuth`. For a dogleg, run `armDownrangeGuidance` with the initial azimuth, then issue your own `LOCK STEERING TO HEADING(newAzimuth, ...).` later in the ship script. The guidance loop will be overridden until you re-lock through it.

## Tuning checklist

1. **Validate altitude ordering.** `turnStartAlt < kickEndAlt < turnEndAlt < guidanceEndAlt`. The function logs a `critical` message and returns 90 if Phase 1/2 are mis-ordered, but `guidanceEndAlt` is not validated - put it above `turnEndAlt` or guidance never finishes.
2. **Match `kickPitch` to TWR.** Low-TWR vehicles benefit from a sharper kick (lower `kickPitch`); high-TWR vehicles can afford a gentler one.
3. **Pick `turnShape` from the burn profile.** If your vehicle still has plenty of dV at `turnEndAlt`, lower `turnShape` to bleed off vertical earlier. If it's running close to MECO at `turnEndAlt`, raise `turnShape` so you stay vertical longer.
4. **Set `guidanceEndAlt` above the worst-case turn-end.** Otherwise Phase 3 never runs and the surface-prograde handoff is skipped.
5. **Decide what happens after.** Sounding flights: `lockProgradeAfterGuidance = TRUE` so the rocket arcs gracefully to apogee. Orbital flights: `lockProgradeAfterGuidance = FALSE` and let your circularisation script take over.
6. **Simulate first.** RSS is unforgiving; the in-game simulation feature is free, career flights are not.

## Notes
RSS scale: do not port stock-tuned numbers, the real-scale planet changes everything. Wind and aerodynamic load on RO/RP1 will also push the vessel off the locked heading - the guidance commands a target attitude, the autopilot's response depends on reaction wheels, gimbal authority, and Q at the moment. Watch for control oscillation in the early kick if the vehicle is aerodynamically marginal; raise `turnStartAlt` slightly to clear max-Q before turning.
