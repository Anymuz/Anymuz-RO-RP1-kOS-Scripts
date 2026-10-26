# Script System Manual

A practical guide to how this repository actually works when a ship boots, loads,
launches, updates the GUI, and hands control between shared libraries, family
programs, and ship entry scripts.

This manual is meant to be read slowly while you browse the code. It does not try
just to list functions. It explains who owns what, why the files are split the
way they are, and where to make changes without breaking the rest of the system.

If you are ever unsure where a behavior comes from, start with the execution path
in section 2, then jump to the layer named in section 3.

---

## 1. What this system is trying to do

This repo is a layered kOS flight-control framework for KSP/RO-RP1.

At a high level it does five jobs:

1. Boot a vessel cleanly from a very small boot script.
2. Work out which ship is currently loaded.
3. Load the correct ship entry script for that vessel.
4. Reuse shared libraries for launch, tracking, audio, logging, destruct,
   parachutes, staging, and GUI.
5. Keep ship-specific decisions near the ship while keeping reusable behavior in
   shared libraries.

That split is the main architectural idea of the whole repo:

- `boot/` gets the computer running.
- `system/` identifies the vessel and dispatches to the correct ship script.
- `lib/` holds reusable capabilities, including the shared GUI toolkit in
  `lib/gui/` (widgets and shared panels only, not any one family's screen).
- `programs/` defines a family of related ships and its flight logic.
- `gui/` holds one dashboard file per family (for example `gui/breshit.ks`):
  that family's window layout plus the panels unique to it, filtered by variant
  logic. The family program loads it.
- `ships/` defines one exact vessel and its startup GUI values.

The GUI is important, but it is not the center of the architecture. The ship
would still fly if the GUI did not exist. The GUI reads state, exposes controls,
and calls existing functions. It does not replace the flight-control libraries.

Treat a family's dashboard the same way you treat its flight logic. The shared
widgets live in `lib/gui/`, but the actual screen for a family is assembled in
that family's own dashboard file. Think car brands: every dashboard is built from
the same parts catalogue, but an Audi dash and a BMW dash are laid out for that
car and expose controls only for what that car can do. `gui/breshit.ks` is
Breshit's dashboard: it builds the tabs and filters panels with variant logic,
and it sits as a sibling to `programs/breshit.ks`, not inside `lib/gui/`.

---

## 2. The real execution path

When you boot a ship, the code runs in a strict top-down chain. If you keep this
sequence in your head, the rest of the repository becomes much easier to read.

### Step 1: `boot/boot.ks`

The boot file is intentionally tiny because kOS boot storage is constrained.

What it does:

- waits for the vessel to unpack
- waits another short moment for stability
- opens the terminal
- runs `0:/system/main.ks`

This file should stay tiny and boring. It exists only to get you into the real
system without hitting boot-file storage limits.

### Step 2: `system/main.ks`

This is the first real script in the framework.

Its job is to create the global state that everything else assumes exists.

What it sets up:

- logging, via `lib/logging.ks`
- ship identity globals
- the `flightData` shared lexicon
- utility helpers
- audio helpers
- dispatch into `system/loadShip.ks`

Important globals created here:

- `shipName`: exact `SHIP:NAME`
- `shipSeries`: the text before `-` in the ship name
- `shipVariant`: the text after `-`, or `N/A`
- `flightData`: shared mission telemetry and phase state

This file is not where you add ship logic. This file exists so ship logic has a
known environment when it starts.

### Step 3: `system/loadShip.ks`

This is the dispatcher.

It decides which ship entry script should run based on the vessel name.

Naming rule:

- If the vessel name contains `-`, it is treated as `<family>-<variant>`.
- The script path becomes `0:/ships/<family-lowercase>/<full-vessel-name>.ks`.
- If there is no `-`, the script path becomes `0:/ships/<full-vessel-name>.ks`.

Example:

- `Breshit-R1` becomes `0:/ships/breshit/Breshit-R1.ks`

If the file exists, it is `RUNPATH`ed.
If it does not exist, the system falls through to `system/failureInfo.ks`.

This is why naming is not cosmetic in this repo. A ship name is part of the
routing system.

### Step 4: `ships/<family>/<ShipName>.ks`

This is the actual entry point for a specific vessel.

A ship entry script is where you compose a mission from existing pieces.

Typical responsibilities:

- load the family program from `programs/`
- set per-ship startup values
- seed editable GUI parameters
- call the family/program initialization
- run the launch sequence
- arm post-launch systems
- keep the program alive with `WAIT UNTIL FALSE.`

The ship script is the best place to answer questions like:

- Which exact vehicle is this?
- What should its destruct altitude start as?
- Which systems are armed after launch?
- Which shared family behavior does this vehicle opt into?

### Step 5: `programs/<family>.ks`

The family program sits between shared libraries and an individual ship.

It is where common behavior for a class of vehicles lives.

For Breshit, that includes:

- importing the shared flight libraries
- loading the family dashboard file (`gui/breshit.ks`)
- declaring family-wide globals
- mapping variants to engine tags and destruct capabilities
- registering armable systems for the GUI automation layer
- startup behavior such as `activateSystems()` and init messaging

If multiple ships in a family need the same structure but different values, the
shared logic belongs here and the values belong in the ship script.

---

## 3. The five layers and how to think about them

A good way to work in this repo is to treat every file as living in one of five
layers.

### Layer 1: Boot

Files:

- `boot/boot.ks`
- optional alternate boot scripts under `boot/`

Question this layer answers:

- How does the kOS computer get into the framework at all?

Change this layer only when you want a different startup entry point, such as a
special test harness.

### Layer 2: System bootstrap and dispatch

Files:

- `system/main.ks`
- `system/loadShip.ks`
- `system/failureInfo.ks`
- `system/testAudio.ks`

Questions this layer answers:

- What globals must exist before ship code runs?
- How is the current vessel resolved to a ship script?
- What happens if boot fails?

This layer should stay generic. It should know how to start ships, not how to fly
one particular rocket.

### Layer 3: Shared libraries

Files:

- `lib/logging.ks`
- `lib/utils.ks`
- `lib/resources.ks`
- `lib/launch.ks`
- `lib/booster.ks`
- `lib/tracking.ks`
- `lib/downrange.ks`
- `lib/detonation.ks`
- `lib/parachute.ks`
- `lib/staging.ks`
- `lib/audio.ks`
- `lib/sounds/*.ks`
- `lib/gui/gui.ks`
- `lib/gui/guiTheme.ks`
- `lib/gui/guiCore.ks`
- `lib/gui/guiAutomation.ks`
- `lib/gui/guiPanels.ks`
- `lib/gui/panels/*.ks`
- `lib/gui/guiDashboard.ks`

Questions this layer answers:

- How do we perform a reusable capability?
- How do we monitor or arm a recurring system?
- How do we log, play sounds, track stats, or detect failures?
- How do we provide reusable GUI primitives (widgets, panels, refresh loop,
  automation registry, default dashboard)?

Libraries should be reusable and mostly behavior-oriented. They should not decide
which ship variant exists or which family-specific values to use.

The same rule applies to `lib/gui/`. It supplies the widgets, the refresh loop,
the automation registry, and generic reusable panels, but it never decides which
tabs a particular family shows. That composition is a program-layer decision
(see section 7).

### Layer 4: Family programs and dashboards

Files:

- `programs/breshit.ks` (family flight logic)
- `gui/breshit.ks` (family dashboard: layout + that family's unique panels)
- other family files in `programs/` and `gui/`

Questions this layer answers:

- What do all vehicles in this family have in common?
- Which libraries does this family use?
- Which family-wide globals and thresholds exist?
- What does the family dashboard look like (tab set, panel composition,
  family-only panels), and how does it filter by variant?

This layer is where generic capability becomes vehicle-family behavior. The
program file owns flight logic and system registration; the `gui/` file owns the
dashboard for the same family and is loaded by the program.

### Layer 5: Ship entry scripts

Files:

- `ships/breshit/Breshit-R1.ks`
- other files under `ships/`

Questions this layer answers:

- What exact vessel am I flying right now?
- What startup values should this one ship use?
- Which systems are armed for this one mission?
- Which per-ship GUI startup values should be seeded (for example `guiParams`
  defaults)?

This is the most concrete layer. If a decision is unique to a single craft, it
belongs here unless you are intentionally generalizing it.

---

## 4. Shared state: the wires between layers

Because KerboScript does not give you a rich object system for this kind of
architecture, the framework uses a few shared globals as wiring between modules.

These globals are important because they tell you who owns data and who is merely
reading it.

### `flightData`

Created in `system/main.ks`.

Purpose:

- shared live mission state
- flight phase
- max values captured during ascent or flight
- descent state
- apoapsis-related readings

Typical readers/writers:

- tracking code updates it
- GUI telemetry panels display it
- launch and post-launch systems read `phase`

When to use it:

- use it for mission telemetry shared across subsystems
- do not use it for GUI configuration or one-off editable mission parameters

### `logConfig`

Owned by the logging system.

Purpose:

- where and how logs are written
- timestamp settings
- active log file path

Typical use:

- family programs configure it
- libraries and ships write through `logMessage`

### `guiConfig`

Created in the GUI core.

Purpose:

- window size and position
- refresh interval
- logo/background behavior
- engine tag used by GUI panels
- visibility of certain controls such as manual destruct

This is GUI configuration, not mission logic.

### `guiParams`

Created in the GUI core.

Purpose:

- editable mission values shared between ship/program logic and GUI controls

Pattern:

1. ship script seeds a starting value
2. panel builder binds a field to the same key
3. later logic reads the same key when needed

Example flow:

- ship seeds `guiParams["destructAlt"]`
- Breshit destruct panel exposes that key on the RECOVERY tab
- system registration later reads `guiParams["destructAlt"]` when arming auto-destruct

Important rule:

There is no active dedicated params tab. Editable inputs live on the panel for
the system they control.

### `guiState`

Owned by the GUI engine.

Purpose:

- the actual GUI window handle
- widget registry
- updater list
- refresh trigger state

Do not manually write to this unless you are extending the GUI framework itself.

### `guiSystems`

Owned by `lib/gui/guiAutomation.ks`.

Purpose:

- registered armable systems
- AUTO/MANUAL state for each system
- the action used to arm each system

This is the bridge between flight automation and the GUI automation panel.

---

## 5. How the libraries are meant to be used

The `lib/` folder is not just a random bag of helpers. It contains two broad
kinds of code.

### Pure or near-pure helpers

These are functions that answer questions or format data.

Examples:

- resource summing
- thrust/TWR calculations
- formatting or value helpers
- sound lookup helpers

These are the easiest to reuse because they do not own long-running mission
state.

### Orchestration functions

These are higher-level functions that start long-running behavior.

Examples:

- launch sequencing
- engine monitoring
- booster separation arming
- destruct arming
- parachute deployment monitors
- tracking loops or triggers

These functions often:

- set locks
- arm `WHEN ... THEN` triggers
- depend on global state already existing
- expect the ship/program to have set thresholds first

This distinction matters because orchestration functions are not safe to call at
random import time. That is why the repo keeps side effects out of top-level
library code and expects programs or ship scripts to call the functions in a
chosen order.

---

## 6. The launch path in plain English

The launch system is a good example of the architecture because it touches most
layers without mixing responsibilities.

### The generic launch library

`lib/launch.ks` contains the reusable launch behavior.

Core pieces:

- `commandLaunch()` sets a flag used by GUI or action-based launch release.
- `initializeLaunch()` waits for either a keypress or a launch command.
- `countdownLaunch()` performs the countdown and audio.
- `launchShip()` actually stages and transitions the flight phase.

Notice what this library does not know:

- which exact ship is flying
- what family it belongs to
- whether a ship wants a GUI
- what post-launch systems should arm afterwards

That is intentional.

### The ship script composes the mission

In a Breshit ship, the ship script decides to call:

1. `initializeLaunch()`
2. `countdownLaunch()`
3. `launchShip()`

Then, after liftoff, it decides which post-launch systems to arm.

This means the ship script owns mission ordering even though the detailed logic
lives in libraries.

---

## 7. GUI is a program-layer responsibility

The GUI is not a separate track bolted onto the side. It follows the same
ownership rule as flight code, and the decisive layer is the program layer.

Think of it as the parallel to how a family program owns flight behavior:

- `lib/gui/*` is just the toolkit: widgets, the refresh loop, the automation
  registry, and generic reusable panels. It is a library like any other.
- `gui/<family>.ks` owns the actual screen for a family. It decides which tabs
  exist, which panels go on them, and which family-only panels to add. It filters
  that composition with logic (variant flags, part-tag checks) exactly the way the
  program filters flight behavior. The family program loads this file.
- `ships/*` only seeds per-ship starting values (for example `guiParams`
  defaults) and then calls the family GUI.

So when you ask "where does this GUI decision live?", the answer is almost always
the same as for flight behavior: shared mechanism in `lib/gui/`, the actual family
screen and its filtering in `gui/<family>.ks`, one-off values in the ship.

`startBreshitGui()` in `gui/breshit.ks` is the model to copy. It builds a
variant-appropriate tab list, adds the shared panels, conditionally adds
Breshit's own tuning and destruct panels, and shows only what that vehicle
actually needs. The rest of this section walks the toolkit files first, then that
family dashboard.

### `lib/gui/gui.ks`

This is only a loader.

It `RUNONCEPATH`s the shared GUI toolkit (theme, core, automation, dashboard
helpers) so a ship or program can load one file and get the engine. It does not
load the panel builders - each family loads only the panels it shows in its
`gui/<family>.ks`, and the generic `startDashboard` fallback pulls the full set on
demand via `guiUseStandardLayout()`.

### `lib/gui/guiTheme.ks`

This is the styling layer.

It owns:

- colors
- text styling helpers
- status-colored text helpers
- shared visual constants

If the GUI looks wrong, starts here. If the GUI behaves wrong, it probably is not
here.

### `lib/gui/guiCore.ks`

This is the engine of the GUI.

It owns:

- `guiConfig`
- `guiParams`
- `guiState`
- window creation and disposal
- named widget registration
- updater registration
- shared widget factories such as headings, rows, buttons, fields, and tabs
- the refresh trigger that keeps live labels updated

The two most important GUI ideas are:

#### Live rows need an updater

A label does not update itself in kOS.

So the framework uses this pattern:

1. create a row and give the value label a unique name
2. register an updater delegate
3. every refresh cycle, that updater rewrites the label text

#### Buttons must stay instant

GUI callbacks run like triggers.

That means a button action must not do long waits. If an action needs time, the
button should set a flag and normal flight code should do the waiting.

### `lib/gui/guiAutomation.ks`

This file solves a specific problem: letting the pilot override some automatic
systems at runtime.

It stores registered systems in `guiSystems`.
Each system has:

- a name
- an arm action
- an armed state
- a manual/auto state

The AUTOMATION panel reads this registry and lets the pilot flip systems between
AUTO and MANUAL.

This does not replace the actual flight logic. It inserts a decision point before
that logic fires.

### `lib/gui/panels/*.ks`

Each panel file builds one box of related UI.

Examples:

- telemetry
- launch
- recovery
- engine
- systems
- controls
- audio
- automation

A panel builder usually:

1. creates a box
2. adds headings and rows
3. binds buttons or editable fields
4. optionally registers updaters for live values
5. returns the box

Panels should stay focused by subject. If a field tunes recovery behavior, it
belongs on a recovery-oriented panel, not in a catch-all bucket.

### `lib/gui/guiDashboard.ks`

This is the generic tabbed dashboard layer.

It defines a layout as data and can build a standard dashboard automatically.
Some ships can use it directly. Others, such as Breshit, can build a custom
window composition themselves.

### Family-specific GUI composition

Breshit is a good example of customizing the GUI without modifying the shared GUI
framework.

`gui/breshit.ks` defines `startBreshitGui()` and Breshit's launch, engine, and
systems panels. The defaults provider is `programs/breshit.ks`.
`startBreshitGui()`:

- resets the `userInputs` lexicon from `breshitDefaults`
- establishes the launch-origin position before the first telemetry refresh
- builds launch, science, engine, resources, and systems tabs
- shows the window and arms the refresh timer

That is exactly where this kind of customization belongs: not in the shared GUI
engine, but in the family's own dashboard file that sits beside its program.

---

## 8. A full Breshit example from boot to auto-destruct

This is the best concrete example to follow while reading the code.

### Startup

The family startup should:

1. load `programs/breshit.ks` for the default input values
2. load `gui/breshit.ks` and its shared library dependencies
3. call `resetBreshitDefaults()` before registering systems that read `userInputs`
4. register the Breshit automation systems
5. call `startBreshitGui()`

At this point, the ship has both flight libraries and a live GUI.

### GUI binding

`buildBreshitSystemsPanel()` binds the destruct controls to the same `userInputs`
lexicon populated from `breshitDefaults`:

- `userInputs["destructAlt"]`
- `userInputs["useRadarAlt"]`

These keys are initialized before panel construction, so each field displays the
active value and edits the value read by the registered action.

### System registration

The family program registers a `Destruct` automation system for variants that
support auto-destruct. The third `registerSystem()` parameter selects its
register-time MANUAL mode:

```ks
registerSystem("Destruct", {
    armAltitudeDetonation(userInputs["destructAlt"], userInputs["useRadarAlt"]).
}, FALSE). // Pass TRUE to register the system in MANUAL mode
```

### Post-launch

After launch, the ship script calls `autoArmSystems()`.

That walks through the registered systems and arms them. MANUAL mode is set when
the system is registered; the live Breshit dashboard does not provide an
in-flight automation-mode switch. Automatic destruct checks that registered mode
before it can fire.

The result is a clean multi-layer flow:

- `programs/breshit.ks` owns the default values
- the family dashboard exposes them
- family program registers the behavior
- shared automation layer stores the system state
- shared destruct logic uses the selected values

That is the overall design pattern the repo is aiming for.

---

## 9. Where to make changes

When you want to change behavior, the most important question is not "what file
mentions this name?" It is "which layer owns this decision?"

Use this guide.

### Change a value unique to one ship

Edit the ship script in `ships/`.

Examples:

- one vehicle's starting destruct altitude
- one vehicle's countdown default
- one vehicle's launch profile selection

### Change behavior shared by a family

Edit the family program in `programs/`.

Examples:

- which Breshit variants support auto-destruct
- which tabs appear for the family GUI
- family-specific tuning panels
- family-wide part tags or thresholds

### Change reusable capability

Edit `lib/`.

Examples:

- how launch standby works
- how engine monitoring detects a failure
- how flight stats are tracked
- how parachutes are armed

### Change a shared GUI widget or the toolkit

Edit `lib/gui/`.

Examples:

- logo placement
- window sizing defaults
- how a status row is built
- how tabs are rendered
- shared panel composition helpers

### Change a family's dashboard (tabs, layout, its unique panels)

Edit `gui/<family>.ks`.

Examples:

- which tabs a family shows and in what order
- which shared panels go on each tab
- a panel unique to that family (for example Breshit tuning or destruct)
- variant filtering of the dashboard

### Change boot or routing behavior

Edit `boot/` or `system/`.

Examples:

- custom startup harness
- different ship naming rules
- a different dispatch strategy

---

## 10. Why the repo prefers programs plus ships instead of one script per rocket

This split is the core maintainability win of the repo.

If every rocket had one giant standalone file, you would duplicate:

- launch logic
- logging setup
- GUI composition patterns
- engine monitoring patterns
- destruct integration
- tracking integration

Instead, this structure gives you reuse at two levels:

- `lib/` shares capability across every family
- `programs/` shares family behavior across every ship in that family

Then `ships/` only needs to say what is different.

This keeps concrete mission scripts readable because they are mostly a sequence of
choices and calls, not a reimplementation of the whole framework.

---

## 11. Common coding patterns in this repo

Once you notice these patterns, the code reads much faster.

### `RUNONCEPATH` for libraries, `RUNPATH` for entry scripts

- `RUNONCEPATH` loads reusable code once.
- `RUNPATH` hands control to a script that should execute as an entry point.

### Globals for cross-module shared state, locals for immediate work

- `GLOBAL` is used when multiple modules need the same state.
- `LOCAL` is used for function-internal values.

### Triggers for long-running monitoring

Functions in shared libraries often arm `WHEN ... THEN` triggers for ongoing
behavior.

That lets the ship script say "start watching this system now" without having to
manage the low-level polling loop itself.

### GUI callbacks as tiny delegates

Buttons and updaters use delegates.
They should stay short and immediate.
If a callback needs a long sequence, it should set a flag and let normal program
flow handle it.

### Layout by boxes, not coordinates

The GUI is built by stacking widgets into boxes and tab pages. You generally do
not position things by absolute x/y coordinates.

---

## 12. A reading order that works

If you want to understand the repo without drowning in details, read in this
order.

### First pass: how the system starts

1. `README.md`
2. `boot/boot.ks`
3. `system/main.ks`
4. `system/loadShip.ks`
5. one ship script you actually fly
6. that ship's family program

### Second pass: the reusable flight capabilities

1. `lib/logging.ks`
2. `lib/utils.ks`
3. `lib/resources.ks`
4. `lib/launch.ks`
5. whichever post-launch libraries your ship uses most

### Third pass: the GUI toolkit and where a family composes it

1. `lib/gui/README.md`
2. `lib/gui/gui.ks`
3. `lib/gui/guiCore.ks`
4. `lib/gui/guiAutomation.ks`
5. `lib/gui/panels/*.ks`
6. the family dashboard file, for example `gui/breshit.ks` (`startBreshitGui`)

This reading order mirrors the actual runtime flow and keeps abstractions from
appearing before the code that uses them.

---

## 13. How to add something new without fighting the architecture

### Add a new ship in an existing family

1. copy an existing ship file in that family
2. rename it to match the exact in-game vessel name
3. change the per-ship values at the top
4. keep the existing flow unless this ship really needs a different one

### Add a new family

1. create `programs/<family>.ks`
2. import the shared libraries that family needs
3. declare family-wide globals and variant selection rules
4. create `gui/<family>.ks` with that family's `startXxxGui` dashboard, and load
   it from the program with `RUNONCEPATH`
5. create one or more ship entry files under `ships/<family>/`
6. test that `SHIP:NAME` resolves to the expected path in `loadShip.ks`

### Add a new reusable capability

1. put the behavior in `lib/<name>.ks`
2. keep import-time side effects out of the top level
3. document what globals the function expects to already exist
4. have the relevant family program `RUNONCEPATH` it
5. let ship scripts decide when to call it

### Add a new GUI field

1. decide whether the value already exists as a normal global
2. if yes, bind a `guiAddNumberField` directly to that global
3. if no, seed a key in `guiParams`
4. place the field on the panel for the system it controls
5. read that value later from the same global or key

### Add a new GUI panel

If it is genuinely shared across families:

1. create a builder in `lib/gui/panels/`
2. add it to the `lib/gui/guiPanels.ks` bundle (for the fallback/sandbox)
3. in each `gui/<family>.ks` that shows it, `RUNONCEPATH` the panel file and list
   its builder in that family's layout
4. keep it focused on one subject

If it is unique to one family:

1. define the builder in that family's `gui/<family>.ks`
2. place it in that family's `startXxxGui` layout, filtered by variant if needed
3. keep it focused on one subject

---

## 14. Common failure modes and what they usually mean

### The ship does not boot the expected script

Usually means one of these:

- vessel name does not match the file name
- family folder name does not match the lowercase series prefix
- ship file is not in the path `loadShip.ks` expects

### A GUI number never changes

Usually means:

- the row exists, but no updater was registered
- the updater writes to the wrong widget name
- the GUI refresh loop was not armed

### A GUI button freezes things

Usually means:

- a callback performed a `WAIT`

### A tunable value changes in the GUI but affects nothing

Usually means:

- you seeded a `guiParams` key and exposed a field
- but the later flight logic still reads some other variable instead

### A library behaves strangely when loaded

Usually means:

- top-level side effects are happening too early
- a function expects global state that was not initialized yet

---

## 15. The main mental model to keep

If you only remember one model, use this one:

- `boot/` starts the machine.
- `system/` prepares shared state and finds the ship.
- `lib/` provides reusable abilities.
- `programs/` turns those abilities into a family design.
- `gui/` holds each family's dashboard (layout + its unique panels), loaded by
  the family program and filtered by variant logic.
- `ships/` chooses the exact mission flow for one vessel.
- `lib/gui/` is the shared GUI toolkit that every family's dashboard is built
  from; the ship only seeds starting values.

When the repo feels large, do not think in terms of files first. Think in terms
of ownership.

Ask:

- Is this a startup concern?
- A reusable capability?
- A family-wide rule?
- A one-ship choice?
- A GUI display/control concern?

Once you answer that, the correct file is usually obvious.

---

## 16. Recommended companion docs

This manual is the broad map. These docs are the best detailed companions.

- `README.md` for the top-level repo map
- `docs/system/main.md` for bootstrap globals
- `docs/system/loadShip.md` for naming and dispatch rules
- `docs/lib/launch.md` for launch sequencing details
- `lib/gui/README.md` for the GUI explanation and practical recipes
- `lib/gui/REFERENCE.md` for the full GUI API

Use this manual to understand where things belong. Use the per-script docs when
you need exact signatures and behavior details.
