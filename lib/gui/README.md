# kOS GUI System

A ship's family program builds one dashboard window, assembled from small
**panel** builder functions. This toolkit handles window creation, live-value
refreshing, and click handling so panels can just describe *what* to show.

It does not fly the vessel, lock steering, or stage — panels only read shared
state and call existing `lib/*.ks` functions. Targets kOS **1.1.0+**; GUI
widgets need the mouse and don't work over telnet, so keep terminal logging as
the primary flight interface.

---

## How it works

Everything here is one of four things:

- **A box** — an invisible container that stacks widgets top-to-bottom (`VBOX`)
  or side-by-side (`HLAYOUT`). The window itself is a box; every panel builder
  is handed a `parentBox` and builds inside it — you never set x/y coordinates.
- **A widget** — a label, button, checkbox, or field, made by a `guiAdd...`
  factory in `guiCore.ks`.
- **A delegate** — a function handed over to be called later: `myFunc@` (an
  existing function — `@` means "don't call it now") or `{ ... }` (inline). A
  button holds a delegate and calls it on click; an *updater* is a delegate the
  refresh timer calls on a schedule.
- **The registry** — `guiState`'s name→widget lookup. A row is drawn once and
  filed under a name; an updater finds it again by that same name and rewrites
  its text. Neither side needs a reference to the other, so **every name must
  be unique** or two rows silently fight over one label.

One timed `WHEN` trigger (`armGuiRefresh`) walks every registered updater a
couple of times a second, forever — that's the entire "live" mechanism.

**A live row is always two calls sharing a name:**

```ks
guiAddStatusRow(panel, "Altitude", "alt").                          // draws the row, files it as "alt"
registerUpdater({ setWidgetText("alt", ROUND(ALTITUDE) + " m"). }). // every refresh, rewrite "alt"
```

Skip the second call and the row shows `--` forever.

> **Rule:** button/toggle/field/updater delegates run as kOS *triggers* — never
> `WAIT` inside one, or it jams the whole trigger system. If an action needs to
> take time (a countdown), have the delegate flip a flag and let your normal
> mainline code (which *can* `WAIT`) react to it.

---

## Files and responsibilities

| File | Responsibility |
| --- | --- |
| `gui.ks` | Loads the toolkit in order: `guiTheme → guiCore → guiAutomation → guiDashboard`. `RUNONCEPATH` this one file. |
| `guiCore.ks` | The engine: window lifecycle, the widget registry, every `guiAdd...` factory, the refresh loop. |
| `guiTheme.ks` | Colours, sizes, and the `colorText`/`statusText`/`barText` rich-text helpers. No widgets. |
| `guiAutomation.ks` | Registry for systems armed at post-launch via one call instead of each directly (see below). |
| `guiDashboard.ks` | Generic fallback (`guiLayout`, `startDashboard`) used by the sandbox and quick tests. |
| `panels/resourcesPanel.ks`, `panels/sciencePanel.ks` | The reusable panels currently shared across families. |
| `programs/<family>.ks` + `gui/<family>.ks` | A family's dashboard: tabs, panel builders (shared or family-only), and any family-only globals a panel edits. |

The rest of the original reusable panel set (telemetry, engine, launch,
recovery, systems, automation, controls, audio) plus its loader `guiPanels.ks`
aren't loaded by default — they were retired once families moved to bespoke
dashboards. Restore a file before relying on it.

**The pattern in current use** — see [gui/breshit.ks](../../gui/breshit.ks): a
family owns one `start<Family>Gui()` function that creates the window, adds tabs
with `guiAddTabs`, and calls its panel builders directly. It does not go through
`guiDashboard.ks`'s generic `guiLayout`/`startDashboard` path — that remains a
fallback for `ships/sandbox.ks` and quick experiments, but most of the panels it
expects are currently retired (see above).

---

## Recipes

### Coloured value

```ks
setWidgetText("power", statusText(charge + " %", "WARNING")).  // NOMINAL/WARNING/CRITICAL -> green/amber/red
```

### Bar / gauge

kOS has no bar widget, so `guiAddBar` builds a self-updating text bar
(`[####------] 40%`) from a percent delegate — row, colouring, and updater all
in one call:

```ks
guiAddBar(panel, "Fuel", {
    RETURN 100 * sumPartResource("HPSFT", "Kerosene") / startFuel.  // must return 0..100
}).
```

### Button

```ks
guiAddButton(panel, "Dump Data", outputFlightData@).   // existing function - note the @
guiAddButton(panel, "Lights On", { LIGHTS ON. }).      // inline, for one-off actions
```

### Guarded (ARM-first) action

For anything destructive or one-way, use `guiAddArmedAction` instead of a plain
button. It draws an ARM checkbox next to the button; the action only fires while
ARM is ticked, and ARM auto-clears immediately after firing. Unticking ARM
yourself first is always safe — nothing fires until the button is pressed while
ticked:

```ks
guiAddArmedAction(panel, "SELF DESTRUCT", { selfDestruct("MANUAL INPUT", 3). }).
```

### Editable pilot input

If the value already exists as a plain `GLOBAL`, bind a field straight to it:

```ks
guiAddNumberField(panel, "Preignite Main Fuel %", boosterPreigniteMainThreshold, {
    PARAMETER newValue.
    SET boosterPreigniteMainThreshold TO newValue.
}).
```

If it doesn't exist anywhere yet, seed a `guiParams` key first, then bind
`guiAddParamField`/`guiAddParamToggle` to that key **on the panel for the system
it controls** — there is no generic PARAMS tab:

```ks
SET guiParams["destructAlt"] TO 30000.                                     // seed once, before building
guiAddParamField(panel, "Safe Destruct Alt (m)", guiParams, "destructAlt"). // bind a field
armAltitudeDetonation(guiParams["destructAlt"], ...).                       // read it back later
```

### Register an armable system

`guiAutomation.ks` lets a family register a system once (a name + a no-arg
arming delegate), then arm every registered system at post-launch with one call
instead of arming each directly:

```ks
// family program, before the dashboard is built:
registerSystem("Destruct", { armAltitudeDetonation(guiParams["destructAlt"], guiParams["useRadarAlt"]). }).
// ship script, post-launch:
autoArmSystems().
```

The autonomous action itself should check `systemManual(name)` before firing
(see `lib/detonation.ks`), which holds it off if the system was registered with
`manual IS TRUE`. **Manual mode is fixed at `registerSystem` time** — there is no
live pilot toggle for it. Don't register anything that fires too fast for a
human to matter (booster separation stays a direct call).

### A ship-specific dashboard

```ks
DECLARE FUNCTION startMyShipGui {
    DECLARE PARAMETER windowTitle IS shipName.

    LOCAL tabNames IS LIST("LAUNCH", "ENGINE", "SYSTEMS").
    createGuiWindow(windowTitle, guiConfig["width"]).
    LOCAL tabs IS guiAddTabs(guiState["window"], tabNames).

    buildMyLaunchPanel(tabs["LAUNCH"]).
    buildMyEnginePanel(tabs["ENGINE"]).
    buildMySystemsPanel(tabs["SYSTEMS"]).

    showGui().
    refreshGui().
    armGuiRefresh(guiConfig["refreshInterval"]).
}.
```

Each `buildXxx` is a plain function: take a box, add rows/buttons, call
`registerUpdater` if anything's live, return the box. Copy
[gui/breshit.ks](../../gui/breshit.ks) as a working starting template.

### Quick experimentation

[ships/sandbox.ks](../../ships/sandbox.ks) opens a GUI-only "ship" (name any
craft `Sandbox`) with one editable panel, so you can try widgets without flying
anything. Reload after an edit with `RUNPATH("0:/ships/sandbox.ks").` in the
terminal.

---

## Gotchas

- **Unique widget names.** Two rows sharing a name silently overwrite each
  other — only the last update wins.
- **Never `WAIT` in a button/toggle/field/updater.** Flip a flag and let
  mainline code wait instead.
- **Reserved locals.** kOS blocks names like `heading`, `node`, `list`, `time`,
  `stage` as local variable names — rename if you see a "clobber… BUILTIN" error.
- **Image paths are archive-relative** (`"docs/images/flag"`, never `0:/...`).
- **Set `guiConfig`/`guiParams` before they're read** — `guiConfig` at window
  build time, `guiParams` the moment your code asks for it.
- **Load order:** `gui.ks` after `logging`, `utils`, and `audio`, and after
  whatever defines the part tags your panels read.
- If a crash leaves an orphaned window, run `CLEARGUIS().` in the terminal.

---

## Images and branding

Image paths are archive-relative: no `0:/`, and `.png` is optional.

```ks
SET guiConfig["logo"] TO "docs/images/flag".
SET guiConfig["logoMode"] TO "header".      // "header" | "background" | "off"
SET guiConfig["logoAlign"] TO "CENTER".
SET guiConfig["logoWidth"] TO 360.
SET guiConfig["logoHeight"] TO 220.
```

Set these before `createGuiWindow` — changing them after requires rebuilding the
window. `"background"` mode stretches `guiConfig["background"]` (or `logo` if
blank) as the window backdrop instead of a header image.

---

## More detail

Every function's exact signature, the module dependency diagram, and the shared
state lexicons (`guiConfig`, `guiParams`, `guiState`) are in
[REFERENCE.md](REFERENCE.md).

---

## Official kOS documentation

- [Making GUIs](https://ksp-kos.github.io/KOS/general/gui.html)
- [Creating GUIs](https://ksp-kos.github.io/KOS/structures/gui.html)
- [Box](https://ksp-kos.github.io/KOS/structures/gui_widgets/box.html)
- [Label](https://ksp-kos.github.io/KOS/structures/gui_widgets/label.html)
- [Button](https://ksp-kos.github.io/KOS/structures/gui_widgets/button.html)
- [Style](https://ksp-kos.github.io/KOS/structures/gui_widgets/style.html)
