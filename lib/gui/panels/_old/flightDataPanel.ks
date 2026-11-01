// EXPLAINATION
// Peak flight stats and log dump button
// --------------------------------------------------------------

// Flight data panel
DECLARE FUNCTION buildFlightDataPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "FLIGHT DATA").

    guiAddStatusRow(panel, "Max Velocity", "fdMaxV").
    guiAddStatusRow(panel, "Apogee Altitude", "fdApoAlt").
    guiAddStatusRow(panel, "Max Pred. Apoapsis", "fdMaxApo").

    guiAddButton(panel, "Dump Flight Data To Log", outputFlightData@).

    registerUpdater({
        setWidgetText("fdMaxV", ROUND(flightData["maxVelocity"], 1) + " m/s").
        setWidgetText("fdApoAlt", ROUND(flightData["apogeeAlt"], 0) + " m").
        setWidgetText("fdMaxApo", ROUND(flightData["maxApoapsis"], 0) + " m").
    }).

    RETURN panel.
}.
