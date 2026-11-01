// EXPLAINATION
// Science experiment toggles, telemetry reveals the rest
// --------------------------------------------------------------

// SCIENCE PANEL
// Experiment row with toggle
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

// Science panel, other experiments added after telemetry toggle
DECLARE FUNCTION buildSciencePanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "SCIENCE").

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
// --------------------------------------------------------------
