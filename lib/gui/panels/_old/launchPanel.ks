// LAUNCH PANEL
// Launch command + countdown input. See docs/lib/gui/panels/launchPanel.md.
// --------------------------------------------------------------

DECLARE FUNCTION buildLaunchPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "LAUNCH").

    // Countdown slider -> launchCountdown.
    LOCAL row IS panel:ADDHLAYOUT().
    LOCAL caption IS row:ADDLABEL(colorText("Countdown", guiTheme["captionColor"])).
    SET caption:STYLE:WIDTH TO guiTheme["captionWidth"].
    SET caption:STYLE:ALIGN TO "LEFT".
    LOCAL cdSlider IS row:ADDHSLIDER(launchCountdown, 0, 30).
    SET cdSlider:STYLE:HSTRETCH TO TRUE.
    SET cdSlider:ONCHANGE TO {
        PARAMETER newValue.
        SET launchCountdown TO ROUND(newValue).
    }.

    // Typed entry -> launchCountdown, and nudge the slider to match.
    guiAddNumberField(panel, "Countdown (s)", launchCountdown, {
        PARAMETER newSeconds.
        SET launchCountdown TO newSeconds.
        SET cdSlider:VALUE TO newSeconds.
    }).

    guiAddStatusRow(panel, "T-minus", "lnCountdown").
    guiAddStatusRow(panel, "Status", "lnStatus").

    guiAddButton(panel, "LAUNCH", commandLaunch@).

    // GUI-side countdown clock. Derived entirely from state the GUI can already
    // see (launchCommanded, launchCountdown, flightData) - no lib changes.
    LOCAL clock IS LEXICON("running", FALSE, "startTime", 0).

    registerUpdater({
        // Start our clock on the rising edge of the LAUNCH command; reset when idle.
        IF launchCommanded AND NOT clock["running"] {
            SET clock["running"] TO TRUE.
            SET clock["startTime"] TO TIME:SECONDS.
        } ELSE IF NOT launchCommanded {
            SET clock["running"] TO FALSE.
        }.

        IF flightData["phase"] <> "prelaunch" {
            setWidgetText("lnCountdown", "T- 0 s").
            setWidgetText("lnStatus", statusText("LIFTOFF!", "NOMINAL")).
        } ELSE IF clock["running"] {
            LOCAL remaining IS CEILING(launchCountdown - (TIME:SECONDS - clock["startTime"])).
            IF remaining < 0 { SET remaining TO 0. }.
            setWidgetText("lnCountdown", "T- " + remaining + " s").
            setWidgetText("lnStatus", statusText("COUNTDOWN", "ALERT")).
        } ELSE {
            setWidgetText("lnCountdown", ROUND(launchCountdown) + " s").
            setWidgetText("lnStatus", statusText("STANDBY", "NOMINAL")).
        }.
    }).

    RETURN panel.
}.

