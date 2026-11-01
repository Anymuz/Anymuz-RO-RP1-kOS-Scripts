// CONTROLS PANEL
// Operator action buttons. See docs/lib/gui/panels/controlsPanel.md.
// --------------------------------------------------------------

DECLARE FUNCTION buildControlsPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "CONTROLS").

    LOCAL row IS panel:ADDHLAYOUT().
    guiAddButton(row, "Silence Alarm", stopAlarmSound@).
    guiAddButton(row, "Dump Data", outputFlightData@).

    RETURN panel.
}.
