# Cosmic Fleet Vehicle Control and Guidance Systems

![Cosmic Fleet flag](docs/images/flag.png)

This document is a general reference for the fictional in-game space agency called the "Cosmic Fleet". It contains the software that pilots and ssupports all missions based on which vessel is loaded into the system.

**Contributions:** This repository is for the systems built during my  time playing this game, you are free  to copy the design approach and reuse scripts in your own gameplay but no PRs or issues please, use this work as reference for your own creative approach for best satisfaction, where varients of this sytem are made for you own kOS repos, if you stick with the design approach and script flow foundations layed out here then credit is aprechiated. Ships will not be shared here, please if using these scripts do so with your own designs and playstyle.

The primary  purpose of this repo is for a video game and to have fun, therefore a certain level simplicity over complexity is adopted so  I am not spending all my time writing code when I want to fly rockets.

## kOS Scripts for KSP (RO/RP1)

KerboScript scripts for the [kOS](https://ksp-kos.github.io/KOS/) mod, written for Kerbal Space Program with the Realism Overhaul / Realistic Progression 1 modset. They cover prelaunch checks, clamp-held ignition, downrange guidance, flight tracking, engine monitoring, an audio driver, a logging system, and a safety destruct.

This is a personal project that grows mission by mission. Layout and conventions are stable, but ships, programs, and tunings are added or changed as new vehicles are designed and flown. Scripts are tested in the in-game simulation feature before being used on career flights.

## Usage
These scripts are largely dependent on my ship designs but if you want to make a copy to adapt to your own but reuse and adapt libraries or the boot flow be sure to directly clone the contents of this repo to your ``[KSP Directory]\Ships\Script`` folder then use boot.ks on your ships kOS boot file setting in-game.

## Volume layout

All paths below are relative to the kOS archive volume `0:/`.

```
boot/        kOS boot files. Tiny by design - they only kick off main.ks.
system/      Bootstrap, ship dispatch, failure screens, audio test harness.
lib/         Reusable libraries. Pure helpers and orchestration functions.
lib/sounds/  Note tables for the audio driver.
programs/    Per-family mission programs (one .ks per ship family).
ships/       Per-ship entry scripts, organised by family folder.
logs/        Flight logs written by the logger. Contents are gitignored.
docs/        One markdown file per script describing purpose and functions.
```

### Folder purposes

- **boot/** - Set the active boot file in the VAB/SPH on the kOS part. The boot script just waits for the vessel to unpack, opens the terminal, and runs `0:/system/main.ks` (or a test harness). Keep these files small to stay under the kOS module storage limit.
- **system/** - One-time wiring that runs at vessel start. Initialises global flight state, loads shared libraries, dispatches to the right ship script based on `SHIP:NAME`, and contains failure messages for misnamed vessels.
- **lib/** - Library code. Files only declare functions and small `GLOBAL` config lexicons. No vessel control runs at import time. Anything that locks steering, stages, or arms a `WHEN` trigger lives inside a function that the program/ship script calls explicitly.
- **lib/sounds/** - Note and song definitions consumed by `lib/audio.ks`. One file per audio category (launch, alert, alarm).
- **programs/** - One file per ship family (e.g. `bereshit.ks`, `bmidbar.ks`). Imports the libraries the family needs, declares family-wide globals (engine tags, resource names, thresholds), defines family-specific helpers (telemetry action groups, init banner), and configures logging.
- **ships/<family>/<ShipName>.ks** - The actual entry point for one vehicle. Imports its family program, sets per-vehicle tags and tunings, then runs the launch sequence and arms post-launch systems. Vehicles in a series share the family program; tunings live here so two variants can fly differently.
- **logs/** - Output target for `logMessage`. Each ship gets its own `<ShipName>_flightlog.txt`. Contents are gitignored; the folder is kept via `.gitkeep`.
- **docs/** - One markdown file per script. Each doc lists the script's purpose and a one-line summary of every function it exposes. Update the doc when you change a script's public surface; see `docs/_template.md`.

## Boot flow

```
kOS part boots
        |
        v
  boot/boot.ks
   - WAIT UNTIL SHIP:UNPACKED
   - open terminal
   - RUNPATH 0:/system/main.ks
        |
        v
  system/main.ks
   - load lib/logging.ks
   - declare GLOBAL flightData lexicon (phase, max velocities, apogee, etc.)
   - load lib/utils.ks, lib/audio.ks
   - RUNPATH 0:/system/loadShip.ks
        |
        v
  system/loadShip.ks
   - parse SHIP:NAME on '-' to get family + variant
   - resolve 0:/ships/<family>/<SHIP:NAME>.ks
   - if missing -> system/failureInfo.ks
   - else      -> RUNPATH the ship script
        |
        v
  ships/<family>/<ShipName>.ks
   - RUNONCEPATH the family program
   - set per-ship tags, resources, thresholds, guidance profile
   - call init<Family>(electricChargeLevel, shipVariant)
   - run launch sequence (initializeLaunch -> countdownLaunch -> launch...)
   - arm post-launch systems (tracking, engine monitor, downrange, destruct)
   - WAIT UNTIL FALSE
```

## Layer responsibilities

```
+------------------------------------------------------------+
| ships/<family>/<Name>.ks                                   |
|   per-vehicle tags, resources, thresholds, guidance values |
|   composes the launch + post-launch sequence               |
+--------------------------+---------------------------------+
                           |
                           v
+------------------------------------------------------------+
| programs/<family>.ks                                       |
|   imports lib/*                                            |
|   declares family-wide GLOBALs                             |
|   family-specific helpers (telemetry groups, init banner)  |
|   logging setup                                            |
+--------------------------+---------------------------------+
                           |
                           v
+------------------------------------------------------------+
| lib/*.ks                                                   |
|   pure helpers (math, resource sums, TWR, formatting)      |
|   orchestration functions that arm WHEN triggers           |
|   no top-level side effects                                |
+--------------------------+---------------------------------+
                           |
                           v
+------------------------------------------------------------+
| system/*.ks  -  one-time bootstrap                         |
| boot/*.ks    -  minimal entry, runs system/main.ks         |
+------------------------------------------------------------+
```

Read top-down to add a vehicle. Read bottom-up to add a capability that several families will share.

## Logger

All flight-relevant output goes through `logMessage` from `lib/logging.ks`:

```
logMessage(message, messageType, consoleTimestamp, playSound, outputToConsole).
```

`messageType` is a short tag rendered as `[TAG]` in the console and log file. Tags drive optional alert sounds. Stick to existing tags so log files stay greppable. Per-script docs note which tags each script emits.

## Adding a new ship

1. Pick a family. If the family does not exist yet, add `programs/<family>.ks` first.
2. Create `ships/<family>/<ShipName>.ks`. The file name must match the in-game vessel name exactly (case-sensitive, with the `-` separator that `loadShip.ks` splits on).
3. Copy the structure of an existing ship in the same family. Override per-vehicle values at the top.
4. Add a matching `docs/ships/<family>/<ShipName>.md` from `docs/_template.md`.
5. Test in the in-game simulation feature before flying for career.

## Adding a new library

1. Create `lib/<name>.ks`. Functions only, plus optional `GLOBAL` config lexicons. No `LOCK`, `STAGE`, `WAIT`, or `WHEN` at the top level.
2. Add `docs/lib/<name>.md` from the template.
3. Have the relevant `programs/<family>.ks` `RUNONCEPATH` it.

## Conventions

- Statements end with `.`, including closing braces (`}.`).
- 4-space indent, no tabs.
- `camelCase` for functions and variables. Part tags are short uppercase strings on the part itself.
- Prefer `LOCAL` for function-internal state. `GLOBAL` only for cross-module shared state (`flightData`, `shipName`, `logConfig`).
- Prefer `SHIP:PARTSTAGGED("...")` over part-name lookups so part renames in mods do not break scripts.
- Libraries import with `RUNONCEPATH`. Entry/dispatch scripts use `RUNPATH`.

## Per-script docs index

| Script | Doc |
| --- | --- |
| `boot/boot.ks` | [docs/boot/boot.md](docs/boot/boot.md) |
| `boot/audioTests.ks` | [docs/boot/audioTests.md](docs/boot/audioTests.md) |
| `system/main.ks` | [docs/system/main.md](docs/system/main.md) |
| `system/loadShip.ks` | [docs/system/loadShip.md](docs/system/loadShip.md) |
| `system/failureInfo.ks` | [docs/system/failureInfo.md](docs/system/failureInfo.md) |
| `system/testAudio.ks` | [docs/system/testAudio.md](docs/system/testAudio.md) |
| `lib/logging.ks` | [docs/lib/logging.md](docs/lib/logging.md) |
| `lib/audio.ks` | [docs/lib/audio.md](docs/lib/audio.md) |
| `lib/utils.ks` | [docs/lib/utils.md](docs/lib/utils.md) |
| `lib/launch.ks` | [docs/lib/launch.md](docs/lib/launch.md) |
| `lib/booster.ks` | [docs/lib/booster.md](docs/lib/booster.md) |
| `lib/tracking.ks` | [docs/lib/tracking.md](docs/lib/tracking.md) |
| `lib/downrange.ks` | [docs/lib/downrange.md](docs/lib/downrange.md) |
| `lib/detonation.ks` | [docs/lib/detonation.md](docs/lib/detonation.md) |
| `lib/sounds/launchSounds.ks` | [docs/lib/sounds/launchSounds.md](docs/lib/sounds/launchSounds.md) |
| `lib/sounds/alertSounds.ks` | [docs/lib/sounds/alertSounds.md](docs/lib/sounds/alertSounds.md) |
| `lib/sounds/alarmSounds.ks` | [docs/lib/sounds/alarmSounds.md](docs/lib/sounds/alarmSounds.md) |
| `programs/bereshit.ks` | [docs/programs/bereshit.md](docs/programs/bereshit.md) |
| `programs/bmidbar.ks` | [docs/programs/bmidbar.md](docs/programs/bmidbar.md) |
| `ships/bereshit/Bereshit-R1.ks` | [docs/ships/bereshit/Bereshit-R1.md](docs/ships/bereshit/Bereshit-R1.md) |
| `ships/bereshit/Bereshit-R2.ks` | [docs/ships/bereshit/Bereshit-R2.md](docs/ships/bereshit/Bereshit-R2.md) |
| `ships/bmidbar/Bmidbar-LR1.ks` | [docs/ships/bmidbar/Bmidbar-LR1.md](docs/ships/bmidbar/Bmidbar-LR1.md) |
| Template for new docs | [docs/_template.md](docs/_template.md) |
