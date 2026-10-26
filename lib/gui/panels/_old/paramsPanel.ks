// PARAMS PANEL
// DEPRECATED / UNUSED - editable inputs now live on each system's own panel; kept for reference.
// See docs/lib/gui/panels/paramsPanel.md.
// --------------------------------------------------------------

DECLARE FUNCTION buildParamsPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].
    DECLARE PARAMETER lexIn IS guiParams.
    DECLARE PARAMETER title IS "PARAMETERS".

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, title).

    IF lexIn:KEYS:LENGTH = 0 {
        panel:ADDLABEL(colorText("No parameters. Populate guiParams in the ship script.", guiTheme["mutedColor"])).
        RETURN panel.
    }.

    FOR key IN lexIn:KEYS {
        IF lexIn[key]:ISTYPE("Boolean") {
            guiAddParamToggle(panel, key, lexIn, key).
        } ELSE {
            guiAddParamField(panel, key, lexIn, key).
        }.
    }.

    RETURN panel.
}.
