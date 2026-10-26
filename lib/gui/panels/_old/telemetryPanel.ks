// TELEMETRY PANEL
// Live vessel telemetry (read-only). See docs/lib/gui/panels/telemetryPanel.md.
// --------------------------------------------------------------

// Real-time telemetry sampled from SHIP and the shared flightData lexicon.
DECLARE FUNCTION buildTelemetryPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "TELEMETRY").

    guiAddStatusRow(panel, "Mission Time", "telMet").
    guiAddStatusRow(panel, "Altitude", "telAlt").
    guiAddStatusRow(panel, "Vertical Speed", "telVspd").
    guiAddStatusRow(panel, "Surface Speed", "telSspd").
    guiAddStatusRow(panel, "Apoapsis", "telApo").
    guiAddStatusRow(panel, "Flight Phase", "telPhase").

    registerUpdater({
        setWidgetText("telMet", formatTime(getLogTime(), "MS")).
        setWidgetText("telAlt", ROUND(ALTITUDE, 0) + " m").
        setWidgetText("telVspd", ROUND(SHIP:VERTICALSPEED, 1) + " m/s").
        setWidgetText("telSspd", ROUND(SHIP:VELOCITY:SURFACE:MAG, 1) + " m/s").
        setWidgetText("telApo", ROUND(SHIP:APOAPSIS, 0) + " m").
        setWidgetText("telPhase", colorText(flightData["phase"]:TOUPPER(), guiTheme["accentColor"])).
    }).

    RETURN panel.
}.
