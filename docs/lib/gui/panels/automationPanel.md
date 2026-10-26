# panels/automationPanel.ks

Path: `0:/lib/gui/panels/automationPanel.ks`

## Purpose
GUI panel for automation and manual override. One row per registered system
(`guiAutomation.ks`): a MANUAL checkbox, the system name, and a live
AUTO / MANUAL / STANDBY status. The switch is a live gate - AUTO runs the
system's automatic action, MANUAL holds it (the pilot fires from that system's
own panel).

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- `0:/lib/gui/guiAutomation.ks` (the registry it renders)

## Globals declared
- None. Reads/edits `guiSystems`.

## Functions
- `buildAutomationPanel(parentBox)` - adds an AUTOMATION section: a master **MANUAL CONTROL (ALL)** toggle plus one row per registered system. Shows a hint if none are registered.
- `buildSystemRow(parentBox, sys)` - one system row (Manual checkbox, name, status); returns the checkbox so the master toggle can keep it in sync.

## Notes
The master toggle flips every system to MANUAL/AUTO and syncs the per-row
checkboxes. Firing a held system is done from that system's own panel (e.g. the
RECOVERY tab's SELF DESTRUCT), not here. Systems are populated by the
ship/program via `registerSystem(...)` before the dashboard is built.
