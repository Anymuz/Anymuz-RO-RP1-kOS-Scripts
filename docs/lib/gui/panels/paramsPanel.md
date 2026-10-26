# panels/paramsPanel.ks

**DEPRECATED / UNUSED.** This panel built a generic "PARAMS" tab that auto-listed
every `guiParams` entry. That pattern was retired: editable pilot inputs belong on
the panel that controls the relevant system (e.g. destruct altitude on the
RECOVERY panel), not on a catch-all parameters tab. Not loaded by `guiPanels.ks`
and not placed on any layout - kept on disk only for reference. To make a value
editable now, bind a field to its `guiParams` key with `guiAddParamField`/
`guiAddParamToggle` **on the system's own panel**, or edit a plain `GLOBAL`
directly with `guiAddNumberField`.

Path: `0:/lib/gui/panels/paramsPanel.ks`

## Purpose
GUI panel that turns editable mission parameters into input controls. It
auto-generates a number field for every numeric entry and a checkbox for every
boolean entry in the given lexicon (default `guiParams`). Edits write straight
back into the lexicon.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`

## Globals declared
- None. Reads/edits `guiParams` (owned by `guiCore.ks`) by default.

## Functions
- `buildParamsPanel(parentBox, lex, title)` - adds a section with a control per key in `lex` (default `guiParams`, title `PARAMETERS`). Numbers become number fields; booleans become toggles. Shows a hint if the lexicon is empty.

## Notes
Do not use this builder for new dashboards. Populate the lexicon in your ship
script **after** loading the GUI, then explicitly bind each editable value on any
appropriate panel and read the value where your ship logic needs it:

```
RUNONCEPATH("0:/lib/gui/gui.ks").
SET guiParams["destructAlt"] TO 30000.
SET guiParams["useRadarAlt"] TO FALSE.
// Inside a panel builder chosen by the ship/program:
guiAddParamField(panel, "Safe Destruct Alt (m)", guiParams, "destructAlt").
guiAddParamToggle(panel, "Use Radar Altitude", guiParams, "useRadarAlt").
startDashboard(shipName).
// ... later, at arm time:
armAltitudeDetonation(guiParams["destructAlt"], guiParams["useRadarAlt"]).
```

Adding a key to `guiParams` does not add a field automatically. The field appears
only where its builder calls `guiAddParamField` or `guiAddParamToggle`. The value
is read when your script uses it, so set params before the point that consumes
them (e.g. before the countdown finishes for arm-time parameters).
