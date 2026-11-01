// EXPLAINATION
// Manual toggle and status for each registered system
// --------------------------------------------------------------

// AUTOMATION PANEL
// One row per system, returns the manual checkbox
DECLARE FUNCTION buildSystemRow {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER sys.

    LOCAL row IS parentBox:ADDHLAYOUT().

    LOCAL manualBox IS row:ADDCHECKBOX("Manual", sys["manual"]).
    SET manualBox:ONTOGGLE TO {
        PARAMETER isOn.
        SET sys["manual"] TO isOn.
    }.

    LOCAL nameLabel IS row:ADDLABEL(sys["name"]).
    SET nameLabel:STYLE:HSTRETCH TO TRUE.

    LOCAL statusLabel IS row:ADDLABEL("").
    SET statusLabel:STYLE:WIDTH TO 80.
    SET statusLabel:STYLE:ALIGN TO "RIGHT".

    registerUpdater({
        IF sys["manual"] {
            SET statusLabel:TEXT TO colorText("MANUAL", guiTheme["alertColor"]).
        } ELSE IF sys["armed"] {
            SET statusLabel:TEXT TO statusText("AUTO", "NOMINAL").
        } ELSE {
            SET statusLabel:TEXT TO colorText("STANDBY", guiTheme["mutedColor"]).
        }.
    }).

    RETURN manualBox.
}.

// Automation panel with master manual switch
DECLARE FUNCTION buildAutomationPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "AUTOMATION").

    IF guiSystems:LENGTH = 0 {
        panel:ADDLABEL(colorText("No armable systems registered.", guiTheme["mutedColor"])).
        RETURN panel.
    }.

    LOCAL manualBoxes IS LIST().

    // Master switch
    guiAddToggle(panel, "MANUAL CONTROL (ALL)", FALSE, {
        PARAMETER isOn.
        setAllSystemsManual(isOn).
        FOR box IN manualBoxes {
            SET box:PRESSED TO isOn.
        }.
    }).

    FOR sys IN guiSystems {
        manualBoxes:ADD(buildSystemRow(panel, sys)).
    }.

    RETURN panel.
}.
// --------------------------------------------------------------
