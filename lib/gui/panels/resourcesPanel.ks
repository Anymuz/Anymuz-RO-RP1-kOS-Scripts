// RESOURCES PANEL
// Ship-wide resource overview for any vessel; reusable across ships. See docs/lib/gui/panels/resourcesPanel.md.
// --------------------------------------------------------------

DECLARE FUNCTION buildResourcesPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "RESOURCES").

    LOCAL payloadNames IS LIST().
    LOCAL tankNames IS LIST().
    FOR resourceName IN shipResources:KEYS {
        IF payloadResourceNames:CONTAINS(resourceName) {
            payloadNames:ADD(resourceName).
        } ELSE {
            tankNames:ADD(resourceName).
        }.
    }.

    IF payloadNames:LENGTH > 0 {
        guiAddHeading(panel, "CARGO PAYLOADS").
        FOR resourceName IN payloadNames {
            guiAddStatusRow(panel, resourceName, "res_" + resourceName).
        }.
        guiSpacer(4, panel).
        guiAddHeading(panel, "FUEL AND ENERGY").
    }.

    FOR resourceName IN tankNames {
        guiAddStatusRow(panel, resourceName, "res_" + resourceName).
    }.

    registerUpdater({
        FOR resourceName IN shipResources:KEYS {
            LOCAL resourceWidget IS "res_" + resourceName.
            LOCAL amount IS getResourceAmount(resourceName).
            LOCAL capacity IS getResourceCapacity(resourceName).
            LOCAL percent IS getResourcePercent(resourceName).
            LOCAL key IS "NOMINAL".

            IF percent < 20 {
                SET key TO "WARNING".
            }.
            IF amount <= 0 {
                SET key TO "CRITICAL".
            }.

            setWidgetText(resourceWidget, statusText(ROUND(amount, 1) + " / " + ROUND(capacity, 1) + " (" + percent + "%)", key)).
        }.
    }).

    RETURN panel.
}.
