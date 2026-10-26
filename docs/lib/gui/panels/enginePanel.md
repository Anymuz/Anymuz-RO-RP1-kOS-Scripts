# panels/enginePanel.ks

Path: `0:/lib/gui/panels/enginePanel.ks`

## Purpose
GUI panel showing live, read-only engine metrics. Pure getters, no side effects.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- `0:/lib/resources.ks` (`getResourcePercent`)
- Calls `getTaggedEngineThrust`, `getTaggedEngineMaxThrust`, `getTaggedEngineTWR`, `countTaggedEngines`, `taggedEnginesHaveIgnitionSignal`, `taggedEnginesHaveFlameout` (all `lib/launch.ks`).

## Globals declared
- None. Uses `guiConfig["engineTag"]` for the default part tag and the global `fuelTank` for the fuel row.

## Functions
- `buildEnginePanel(parentBox, engineTag)` - adds an ENGINE section: engine count, current/max thrust, output %, fuel % (`getResourcePercent("", fuelTank)`, whole-tank fill regardless of what resources it holds), TWR, ignition (colour-coded), flameout (colour-coded). `engineTag` defaults to `guiConfig["engineTag"]`.

## Notes
Set `guiConfig["engineTag"]` (or pass a tag) to your vehicle's main-engine part
tag so the numbers match. Default is `"U-1250"`.
