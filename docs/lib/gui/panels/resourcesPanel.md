# panels/resourcesPanel.ks

Path: `0:/lib/gui/panels/resourcesPanel.ks`

## Purpose
GUI panel showing a live, read-only overview of every resource on the vessel.
Reusable across ships - rows are auto-discovered, not hardcoded per ship variant.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- `0:/lib/resources.ks` (`getResourceAmount`, `getResourceCapacity`, `getResourcePercent`, `payloadResourceNames`)
- Calls `refreshShipResources()` to populate the global `shipResources` before deciding which rows to build/update.

## Globals declared
- None.

## Functions
- `buildResourcesPanel(parentBox)` - splits `shipResources:KEYS` into two groups using `payloadResourceNames`: a PAYLOADS section (only shown if the vessel has any) and a TANKS / CONSUMABLES section for everything else. Adds one status row per resource in each group, then registers an updater that re-reads every resource's live amount/capacity/percent every refresh and colours the row (`NOMINAL`/`WARNING`/`CRITICAL`).

## Notes
`parentBox` defaults to `guiState["window"]`. The row set and grouping are fixed at build time from `shipResources:KEYS`; a resource added to the vessel mid-flight will not get a row until the panel is rebuilt. Values shown do update live every refresh. A payload resource reading 0 turns CRITICAL, which doubles as a preflight check that the expected payload is actually aboard.
