# panels/recoveryPanel.ks

Path: `0:/lib/gui/panels/recoveryPanel.ks`

## Purpose
GUI panel for recovery and safety: read-only status derived from `flightData`/
`SHIP`, plus manual actions guarded behind a two-step ARM+fire.

## Imports
- `0:/lib/gui/guiCore.ks`
- `0:/lib/gui/guiTheme.ks`
- Guarded actions call `jettisonChuteFairing` (`lib/parachute.ks`) and `selfDestruct` (`lib/detonation.ks`).

## Globals declared
- None.

## Functions
- `buildRecoveryPanel(parentBox)` - adds a RECOVERY section (phase, descent captured, radar altitude, vertical speed) and a MANUAL section with **Jettison Chute Fairing** and **SELF DESTRUCT**, each behind `guiAddArmedAction` (ARM checkbox must be ticked; auto-disarms after firing).

## Notes
The manual actions are consequential and irreversible in flight. The ARM+fire
guard means a stray single click cannot trigger them - you must tick ARM first.
Do not remove that guard. The **Jettison Chute Fairing** action is only shown if
the vessel actually has `CHUTE-CASE`-tagged fairing parts, so ships without a
parachute (e.g. destruct-recovery sounding rockets) don't see it. The **SELF
DESTRUCT** action is only shown when `guiConfig["manualDestruct"]` is `TRUE`
(default), so a ship/family can hide it on vehicles with no destruct capability;
this is independent of any automatic altitude destruct on the AUTOMATION tab.
