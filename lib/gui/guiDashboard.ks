// EXPLAINATION
// Fallback dashboard for the sandbox and quick tests
// --------------------------------------------------------------

// LAYOUT
// One row per tab: LIST("TAB NAME", builder1@, ...)
GLOBAL guiLayout IS LIST().

// LAYOUT COMPOSITION
// Clears the layout
DECLARE FUNCTION guiResetLayout {
    SET guiLayout TO LIST().
}.

// Adds a tab with its panel builders
DECLARE FUNCTION guiAddTab {
    DECLARE PARAMETER tabName.
    DECLARE PARAMETER builders.

    LOCAL row IS LIST(tabName).
    FOR builder IN builders {
        row:ADD(builder).
    }.
    guiLayout:ADD(row).
}.

// Loads every shared panel as the layout
DECLARE FUNCTION guiUseStandardLayout {
    RUNONCEPATH("0:/lib/gui/guiPanels.ks").
    guiResetLayout().
    guiAddTab("FLIGHT",   LIST(buildTelemetryPanel@, buildFlightDataPanel@)).
    guiAddTab("ENGINE",   LIST(buildEnginePanel@)).
    guiAddTab("LAUNCH",   LIST(buildLaunchPanel@)).
    guiAddTab("RESOURCES", LIST(buildResourcesPanel@)).
    guiAddTab("RECOVERY", LIST(buildRecoveryPanel@)).
    guiAddTab("SYSTEMS",  LIST(buildSystemsPanel@, buildAutomationPanel@, buildControlsPanel@, buildAudioPanel@)).
}.

// Builds the tabbed window from the layout
DECLARE FUNCTION buildDashboard {
    DECLARE PARAMETER windowTitle IS "MISSION CONTROL".
    DECLARE PARAMETER width IS guiConfig["width"].

    IF guiLayout:LENGTH = 0 { guiUseStandardLayout(). }.

    createGuiWindow(windowTitle, width).

    LOCAL tabNames IS LIST().
    FOR row IN guiLayout {
        tabNames:ADD(row[0]).
    }.
    LOCAL tabs IS guiAddTabs(guiState["window"], tabNames).

    FOR row IN guiLayout {
        LOCAL page IS tabs[row[0]].
        FROM { LOCAL i IS 1. } UNTIL i = row:LENGTH STEP { SET i TO i + 1. } DO {
            IF i > 1 {
                guiSpacer(4, page).
            }.
            row[i]:CALL(page).
        }.
    }.

    RETURN guiState["window"].
}.
// --------------------------------------------------------------

// LIFECYCLE
// Builds, shows and starts refreshing
DECLARE FUNCTION startDashboard {
    DECLARE PARAMETER windowTitle IS "MISSION CONTROL".
    DECLARE PARAMETER refreshInterval IS guiConfig["refreshInterval"].

    buildDashboard(windowTitle).
    showGui().
    refreshGui().
    armGuiRefresh(refreshInterval).

    logMessage("Mission control GUI online.", "system", TRUE, FALSE, TRUE).
    RETURN guiState["window"].
}.

// Stops refreshing and destroys the window
DECLARE FUNCTION stopDashboard {
    disarmGuiRefresh().
    disposeGui().

    logMessage("Mission control GUI closed.", "system", TRUE, FALSE, TRUE).
}.
