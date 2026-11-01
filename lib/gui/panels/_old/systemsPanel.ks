// SYSTEMS PANEL
// Systems health: power + alarm state (read-only). See docs/lib/gui/panels/systemsPanel.md.
// --------------------------------------------------------------

DECLARE FUNCTION buildSystemsPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "SYSTEMS").

    guiAddStatusRow(panel, "Electric Charge", "sysPower").
    guiAddStatusRow(panel, "Alarm", "sysAlarm").

    registerUpdater({
        LOCAL charge IS getResourceAmount("ElectricCharge").
        LOCAL powerPct IS getResourcePercent("ElectricCharge").
        LOCAL powerKey IS "NOMINAL".
        IF powerPct < 20 {
            SET powerKey TO "WARNING".
        }.
        IF charge <= 0 {
            SET powerKey TO "CRITICAL".
        }.
        setWidgetText("sysPower", statusText(ROUND(powerPct, 1) + "%", powerKey)).

        IF alarmState["active"] {
            setWidgetText("sysAlarm", statusText(alarmState["name"], "ALARM")).
        } ELSE {
            setWidgetText("sysAlarm", statusText("CLEAR", "NOMINAL")).
        }.
    }).

    RETURN panel.
}.
