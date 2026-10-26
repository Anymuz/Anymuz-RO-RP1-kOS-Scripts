// AUDIO PANEL
// Audio test bench. See docs/lib/gui/panels/audioPanel.md.
RUNONCEPATH("0:/lib/audio.ks").
// --------------------------------------------------------------

DECLARE FUNCTION buildAudioPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "AUDIO TEST").

    LOCAL testRow IS panel:ADDHLAYOUT().
    guiAddButton(testRow, "Alerts", { requestAudioTest("alerts"). }).
    guiAddButton(testRow, "Launch", { requestAudioTest("launch"). }).
    guiAddButton(testRow, "Alarms", { requestAudioTest("alarms"). }).
    guiAddButton(testRow, "Full", { requestAudioTest("full", 5). }).

    LOCAL toneRow IS panel:ADDHLAYOUT().
    guiAddButton(toneRow, "Alert", playAlertSound@).
    guiAddButton(toneRow, "Warn", playWarningSound@).
    guiAddButton(toneRow, "Critical", playCriticalSound@).

    guiAddButton(panel, "Silence Alarm", stopAlarmSound@).

    RETURN panel.
}.
