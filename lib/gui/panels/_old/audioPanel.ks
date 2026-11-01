// EXPLAINATION
// Audio test buttons
// --------------------------------------------------------------

// Audio test panel
DECLARE FUNCTION buildAudioPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "AUDIO TEST").

    LOCAL testRow IS panel:ADDHLAYOUT().
    guiAddButton(testRow, "Alerts", testAlertAudio@).
    guiAddButton(testRow, "Launch", testLaunchAudio@).
    guiAddButton(testRow, "Alarms", testAlarms@).
    guiAddButton(testRow, "Full", fullAudioTest@).

    LOCAL toneRow IS panel:ADDHLAYOUT().
    guiAddButton(toneRow, "Alert", playAlertSound@).
    guiAddButton(toneRow, "Warn", playWarningSound@).
    guiAddButton(toneRow, "Critical", playCriticalSound@).

    guiAddButton(panel, "Silence Alarm", stopAlarmSound@).

    RETURN panel.
}.
