// ENGINE PANEL
// Live engine readouts (read-only). See docs/lib/gui/panels/enginePanel.md.
RUNONCEPATH("0:/lib/resources.ks").
// --------------------------------------------------------------

DECLARE FUNCTION buildEnginePanel {
    DECLARE PARAMETER parentBox IS guiState["window"].
    DECLARE PARAMETER engineTag IS guiConfig["engineTag"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "ENGINE").

    guiAddStatusRow(panel, "Engines", "engCount").
    guiAddStatusRow(panel, "Thrust", "engThrust").
    guiAddStatusRow(panel, "Max Thrust", "engMax").
    guiAddStatusRow(panel, "Output", "engPct").
    guiAddStatusRow(panel, "Fuel", "engFuel").
    guiAddStatusRow(panel, "TWR", "engTwr").
    guiAddStatusRow(panel, "Ignition", "engIgn").
    guiAddStatusRow(panel, "Flameout", "engFlame").

    registerUpdater({
        LOCAL thrustNow IS getTaggedEngineThrust(engineTag).
        LOCAL thrustMax IS getTaggedEngineMaxThrust(engineTag).
        LOCAL outputPct IS 0.
        IF thrustMax > 0 {
            SET outputPct TO ROUND(100 * thrustNow / thrustMax, 0).
        }.

        LOCAL fuelPct IS getResourcePercent("", fuelTank).

        setWidgetText("engCount", "" + countTaggedEngines(engineTag)).
        setWidgetText("engThrust", ROUND(thrustNow, 1) + " kN").
        setWidgetText("engMax", ROUND(thrustMax, 1) + " kN").
        setWidgetText("engPct", outputPct + " %").
        setWidgetText("engFuel", fuelPct + " %").
        setWidgetText("engTwr", "" + ROUND(getTaggedEngineTWR(engineTag), 2)).

        IF taggedEnginesHaveIgnitionSignal(engineTag) {
            setWidgetText("engIgn", statusText("ON", "NOMINAL")).
        } ELSE {
            setWidgetText("engIgn", statusText("OFF", "WARNING")).
        }.

        IF taggedEnginesHaveFlameout(engineTag) {
            setWidgetText("engFlame", statusText("YES", "CRITICAL")).
        } ELSE {
            setWidgetText("engFlame", statusText("NO", "NOMINAL")).
        }.
    }).

    RETURN panel.
}.
