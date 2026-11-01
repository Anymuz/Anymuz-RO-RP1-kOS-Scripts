// EXPLAINATION
// Recovery readouts and armed manual actions
// --------------------------------------------------------------

// Recovery panel
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

    // Manual actions, tick ARM first
    guiAddHeading(panel, "MANUAL (ARM FIRST)").
    IF SHIP:PARTSTAGGED("CHUTE-CASE"):LENGTH > 0 {
        guiAddArmedAction(panel, "Jettison Chute Fairing", { jettisonChuteFairing(). }).
    }.
    IF allowManualDestruct {
        guiAddArmedAction(panel, "SELF DESTRUCT", { selfDestruct("GUI COMMAND", 3). }).
    }.

    RETURN panel.
}.
