// EXPLAINATION
// * GUI panel: toggle RP-1 procedural avionics science experiments.
// * Telemetry has its own permanent row/button - it is never discovered, just
//   assumed present. Pressing it is what triggers the one scan for the rest of
//   the ship's experiments (their EVENT captions only load after an interaction).
// * Depends on lib/gui/guiCore.ks, lib/gui/guiTheme.ks, lib/science.ks.
// --------------------------------------------------------------

// Add one experiment's row: caption, ON/OFF status (registered under its own
// widget name), and a toggle button. A separate function per row gives the
// button's inline delegate its own captured expName, so this is loop-safe.
DECLARE FUNCTION addExperimentRow {
    DECLARE PARAMETER panel.
    DECLARE PARAMETER expName.

    LOCAL row IS panel:ADDHLAYOUT().
    LOCAL widgetName IS "sci_" + expName:REPLACE(" ", "_").

    LOCAL captionLabel IS row:ADDLABEL(colorText(expName, guiTheme["captionColor"])).
    SET captionLabel:STYLE:WIDTH TO guiTheme["captionWidth"].
    SET captionLabel:STYLE:ALIGN TO "LEFT".

    LOCAL statusLabel IS row:ADDLABEL("--").
    SET statusLabel:STYLE:HSTRETCH TO TRUE.
    SET statusLabel:STYLE:ALIGN TO "RIGHT".
    registerWidget(widgetName, statusLabel).

    guiAddButton(row, "Toggle", { toggleExperimentEvent(expName). }).
}.

DECLARE FUNCTION buildSciencePanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "SCIENCE").

    // Nothing is discovered yet - only the guaranteed telemetry row exists
    // until the pilot presses its button.
    LOCAL found IS LIST().

    LOCAL telemetryRow IS panel:ADDHLAYOUT().
    LOCAL telemetryCaption IS telemetryRow:ADDLABEL(colorText(telemetryExperimentName, guiTheme["captionColor"])).
    SET telemetryCaption:STYLE:WIDTH TO guiTheme["captionWidth"].
    SET telemetryCaption:STYLE:ALIGN TO "LEFT".
    LOCAL telemetryStatus IS telemetryRow:ADDLABEL("--").
    SET telemetryStatus:STYLE:HSTRETCH TO TRUE.
    SET telemetryStatus:STYLE:ALIGN TO "RIGHT".
    registerWidget("sciTelemetryStatus", telemetryStatus).

    guiAddButton(telemetryRow, "Toggle Telemetry", {
        toggleExperimentEvent(telemetryExperimentName).

        // Toggling telemetry is what loads the rest of the ship's experiment
        // EVENT captions - scan for them now and add any not already shown.
        FOR expName IN listAvailableExperiments() {
            IF expName <> telemetryExperimentName AND NOT found:CONTAINS(expName) {
                found:ADD(expName).
                addExperimentRow(panel, expName).
            }.
        }.
    }).

    registerUpdater({
        IF getExperimentEnabled(telemetryExperimentName) {
            setWidgetText("sciTelemetryStatus", statusText("ON", "NOMINAL")).
        } ELSE {
            setWidgetText("sciTelemetryStatus", colorText("OFF", guiTheme["mutedColor"])).
        }.

        FOR expName IN found {
            LOCAL widgetName IS "sci_" + expName:REPLACE(" ", "_").
            IF getExperimentEnabled(expName) {
                setWidgetText(widgetName, statusText("ON", "NOMINAL")).
            } ELSE {
                setWidgetText(widgetName, colorText("OFF", guiTheme["mutedColor"])).
            }.
        }.
    }).

    RETURN panel.
}.
