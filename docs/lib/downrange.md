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

## Maximising downrange for a target apoapsis

A suborbital flight has two outputs you care about: how high it apogees and how far downrange it lands. They trade against each other - any dV you spend going horizontal is dV you can't spend going up. The pitch program is what decides that split. The flatter the program, the more range and the less apoapsis. The steeper the program, the more apoapsis and the less range.

To maximise range while still hitting a target apoapsis, the goal is simple: keep the rocket vertical *just long enough* to make the apoapsis target, and from then on bend it over as flat as you can.

### Recipe: 140 km apoapsis with maximum downrange (RSS, kerolox-class)

Use this as a starting point and tune from there - your TWR, drag, and dV will move the numbers around.

```
launchAzimuth                 = 90      // due east, free Earth-rotation bonus
turnStartAlt                  = 0
kickEndAlt                    = 800     // gentle, deliberate kick
kickPitch                     = 75      // keep early flight near vertical
turnEndAlt                    = 55000   // finish the curve well above thick atmosphere
finalPitch                    = 28      // flat enough for range, vertical enough for 140 km
turnShape                     = 0.85    // slightly delay the harder turn for TWR ~1.3-1.6
guidanceEndAlt                = 100000  // hand off above ~95 km, then coast to apo
lockProgradeAfterGuidance     = TRUE    // surface prograde keeps horizontal velocity working
```

Then tune in simulation:

1. Fly the profile, note actual apoapsis.
2. **Apoapsis too low** -> raise `finalPitch` by 2-5 deg (more vertical at burnout). If still short, raise `kickPitch` by 5 deg or raise `turnShape` (e.g. 0.85 -> 1.0) to keep the vehicle vertical longer.
3. **Apoapsis too high** -> lower `finalPitch`. Every degree off vertical you can afford goes straight into more downrange.
4. **Vehicle pitches over too hard early on** (oscillation, lost control under Q) -> raise `turnStartAlt` (e.g. 100-300 m) and/or raise `kickEndAlt` so the kick happens later and shallower.
5. **Vehicle is still climbing nearly vertical at MECO** -> you have spare dV; lower `finalPitch` and rerun.

Iterate until apoapsis sits on target. The first profile that hits 140 km is rarely the best one - keep dropping `finalPitch` until you start *just barely* missing the apoapsis target, then back off one notch. That's your max-range setting for that vehicle.

### Why `finalPitch = 0` is a trap for sounding flights

`finalPitch = 0` means the vehicle is fully horizontal at `turnEndAlt`. That is correct for an orbital first stage handing off to a circularisation routine, but for a ballistic suborbital it kills the apoapsis - the burn ends with almost no vertical velocity and the vehicle barely climbs above `turnEndAlt`. For anything where you actually want altitude, keep `finalPitch` somewhere around 20 or higher.

### Quick "knobs vs outcomes" table

| You want... | Move this | Direction |
| --- | --- | --- |
| More apoapsis, same dV | `finalPitch` | up (more vertical) |
| More downrange, same dV | `finalPitch` | down (more horizontal) |
| Sharper early kick (low-TWR helps gravity losses) | `kickPitch`, `kickEndAlt` | both down |
| Gentler early flight (high-TWR / Q-sensitive vehicle) | `kickPitch` up, `turnStartAlt` up |
| Hold steeper attitude longer through the burn | `turnShape` | up (>1) |
| Shed vertical earlier in the burn | `turnShape` | down (<1) |
| End the program higher / lower | `turnEndAlt`, `guidanceEndAlt` | up / down together |

### What the script does NOT do

This guidance is **open-loop**: it commands a target pitch from altitude alone. It does not measure apoapsis, range, or remaining dV and adjust. If your engines underperform the rocket will follow the same pitch schedule and undershoot apoapsis - the script won't compensate by pitching up. Closed-loop "PEG-style" guidance (target apoapsis + auto-tilt) is a separate problem and is not implemented here.

## Tuning checklist

1. **Validate altitude ordering.** `turnStartAlt < kickEndAlt < turnEndAlt < guidanceEndAlt`. The function logs a `critical` message and returns 90 if Phase 1/2 are mis-ordered, but `guidanceEndAlt` is not validated - put it above `turnEndAlt` or guidance never finishes.
2. **Match `kickPitch` to TWR.** Low-TWR vehicles benefit from a sharper kick (lower `kickPitch`); high-TWR vehicles can afford a gentler one.
3. **Pick `turnShape` from the burn profile.** If your vehicle still has plenty of dV at `turnEndAlt`, lower `turnShape` to bleed off vertical earlier. If it's running close to MECO at `turnEndAlt`, raise `turnShape` so you stay vertical longer.
4. **Set `guidanceEndAlt` above the worst-case turn-end.** Otherwise Phase 3 never runs and the surface-prograde handoff is skipped.
5. **Decide what happens after.** Sounding flights: `lockProgradeAfterGuidance = TRUE` so the rocket arcs gracefully to apogee. Orbital flights: `lockProgradeAfterGuidance = FALSE` and let your circularisation script take over.
6. **Simulate first.** RSS is unforgiving; the in-game simulation feature is free, career flights are not.

## Notes
RSS scale: do not port stock-tuned numbers, the real-scale planet changes everything. Wind and aerodynamic load on RO/RP1 will also push the vessel off the locked heading - the guidance commands a target attitude, the autopilot's response depends on reaction wheels, gimbal authority, and Q at the moment. Watch for control oscillation in the early kick if the vehicle is aerodynamically marginal; raise `turnStartAlt` slightly to clear max-Q before turning.
