// GUI DASHBOARD
// Generic fallback dashboard for the sandbox and quick tests. See docs/lib/gui/.
// --------------------------------------------------------------

// LAYOUT
// The whole dashboard described as data: one row per tab, each
//   LIST("TAB NAME", builder1@, builder2@, ...). Empty by default: a family (or
// the sandbox) fills it with guiResetLayout()/guiAddTab(), loading only the panels
// that vehicle shows. guiUseStandardLayout() populates the full shared set for the
// generic fallback.
GLOBAL guiLayout IS LIST().

// LAYOUT COMPOSITION
// Make the dashboard ship/series specific: call guiResetLayout() then guiAddTab()
// for each system the vehicle actually carries, before startDashboard. A program
// (family) or ship script does this after the GUI is loaded.
DECLARE FUNCTION guiResetLayout {
    SET guiLayout TO LIST().
}.

// Append one tab: a name plus a LIST of panel-builder delegates that stack on it.
DECLARE FUNCTION guiAddTab {
    DECLARE PARAMETER tabName.
    DECLARE PARAMETER builders.

    LOCAL row IS LIST(tabName).
    FOR builder IN builders {
        row:ADD(builder).
    }.
    guiLayout:ADD(row).
}.

// Populate guiLayout with the shared panels currently shipped by the toolkit.
// Purpose-built families can replace this fallback with their own layout.
DECLARE FUNCTION guiUseStandardLayout {
    RUNONCEPATH("0:/lib/gui/guiPanels.ks").
    guiResetLayout().
    guiAddTab("RESOURCES", LIST(buildResourcesPanel@)).
    guiAddTab("SCIENCE", LIST(buildSciencePanel@)).
}.

// Build the tabbed window from guiLayout. Each builder is called with its tab's
// content box; panels sharing a tab are separated by a small spacer.
DECLARE FUNCTION buildDashboard {
    DECLARE PARAMETER windowTitle IS "MISSION CONTROL".
    DECLARE PARAMETER width IS guiConfig["width"].

    IF guiLayout:LENGTH = 0 { guiUseStandardLayout(). }. // fallback: full shared dashboard

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
// Build, show, do a first refresh, and arm the timed refresh trigger.
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

// Stop refreshing, hide, and destroy the dashboard window.
DECLARE FUNCTION stopDashboard {
    disarmGuiRefresh().
    disposeGui().

    logMessage("Mission control GUI closed.", "system", TRUE, FALSE, TRUE).
}.
