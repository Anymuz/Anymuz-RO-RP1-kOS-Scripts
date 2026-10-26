// RECOVERY PANEL
// Recovery status + ARM-guarded manual actions. See docs/lib/gui/panels/recoveryPanel.md.
RUNONCEPATH("0:/lib/parachute.ks").
RUNONCEPATH("0:/lib/detonation.ks").
// --------------------------------------------------------------

DECLARE FUNCTION buildRecoveryPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].
    DECLARE PARAMETER allowManualDestruct IS guiConfig["manualDestruct"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "RECOVERY").

    guiAddStatusRow(panel, "Phase", "recPhase").
    guiAddStatusRow(panel, "Descent", "recDescent").
    guiAddStatusRow(panel, "Radar Alt", "recRadar").
    guiAddStatusRow(panel, "Vert Speed", "recVspd").

    registerUpdater({
        setWidgetText("recPhase", colorText(flightData["phase"]:TOUPPER(), guiTheme["accentColor"])).
        IF flightData["descentCaptured"] {
            setWidgetText("recDescent", statusText("YES", "ALERT")).
        } ELSE {
            setWidgetText("recDescent", statusText("NO", "NOMINAL")).
        }.
        setWidgetText("recRadar", ROUND(ALT:RADAR, 0) + " m").
        setWidgetText("recVspd", ROUND(SHIP:VERTICALSPEED, 1) + " m/s").
    }).

    // Manual actions - each needs ARM ticked first, then auto-disarms. Each shows
    // only when relevant: the chute jettison on craft carrying a "CHUTE-CASE" part,
    // and SELF DESTRUCT whenever the pilot can command a destruct at all
    // (guiConfig["manualDestruct"], which a ship/family sets - default TRUE). This is
    // independent of any automatic altitude destruct on the AUTOMATION tab.
    guiAddHeading(panel, "MANUAL (ARM FIRST)").
    IF SHIP:PARTSTAGGED("CHUTE-CASE"):LENGTH > 0 {
        guiAddArmedAction(panel, "Jettison Chute Fairing", { jettisonChuteFairing(). }).
    }.
    IF allowManualDestruct {
        guiAddArmedAction(panel, "SELF DESTRUCT", { requestSelfDestruct("GUI COMMAND", 3). }).
    }.

    RETURN panel.
}.
