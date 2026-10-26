// AUTOMATION PANEL
// One row per registered system: MANUAL toggle + live AUTO/MANUAL status. See docs/lib/gui/panels/automationPanel.md.
// --------------------------------------------------------------

// One row for a single registered system. Returns the MANUAL checkbox so the
// master toggle can keep it in sync. sys is captured per call (loop-safe).
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
            SET statusLabel:TEXT TO colorText("MANUAL", guiTheme["alertColor"]).   // held - pilot fires it
        } ELSE IF sys["armed"] {
            SET statusLabel:TEXT TO statusText("AUTO", "NOMINAL").                  // armed, fires automatically
        } ELSE {
            SET statusLabel:TEXT TO colorText("STANDBY", guiTheme["mutedColor"]).   // not armed yet
        }.
    }).

    RETURN manualBox.
}.

DECLARE FUNCTION buildAutomationPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "AUTOMATION").

    IF guiSystems:LENGTH = 0 {
        panel:ADDLABEL(colorText("No armable systems registered.", guiTheme["mutedColor"])).
        RETURN panel.
    }.

    LOCAL manualBoxes IS LIST().

    // Master switch: take (or release) manual control of everything at once.
    guiAddToggle(panel, "MANUAL CONTROL (ALL)", FALSE, {
        PARAMETER isOn.
        FOR sys IN guiSystems {
            SET sys["manual"] TO isOn.
        }.
        FOR box IN manualBoxes {
            SET box:PRESSED TO isOn.
        }.
    }).

    FOR sys IN guiSystems {
        manualBoxes:ADD(buildSystemRow(panel, sys)).
    }.

    RETURN panel.
}.
