// BRESHIT DASHBOARD
// Series-specific GUI: Window layout, tabs, and relevent system panels. See docs/lib/gui/.
GLOBAL breshitDefaults IS LEXICON(
    "launchCountdown", 10,
    "boosterPreigniteMainThreshold", 3,
    "ignitionSync", TRUE,
    "separationBoosterPercentage", 5,
    "remainingFuelPercentage", 5,
    "mainEngineStartThreshold", 3,
    "destructAlt", 30000,
    "useRadarAlt", FALSE,
    "hasManualDestruct", TRUE,
    "hasAutoDestruct", FALSE
).
GLOBAL boosterDecouplerTag IS "BOOSTER-DECOUPLER".

RUNONCEPATH("0:/lib/gui/gui.ks"). // Shared GUI toolkit (theme, core, automation, dashboard helpers).
RUNONCEPATH("0:/lib/launch.ks").
RUNONCEPATH("0:/lib/downrange.ks").
RUNONCEPATH("0:/lib/resources.ks").
RUNONCEPATH("0:/lib/science.ks").
RUNONCEPATH("0:/lib/booster.ks").
RUNONCEPATH("0:/lib/parachute.ks").
RUNONCEPATH("0:/lib/detonation.ks").
RUNONCEPATH("0:/lib/gui/panels/resourcesPanel.ks"). // Shared ship-wide resource overview panel.
RUNONCEPATH("0:/lib/gui/panels/sciencePanel.ks"). // Experiment telemetry + dynamic science toggle panel.
// --------------------------------------------------------------

// Reset runtime inputs from this dashboard's defaults.
GLOBAL userInputs IS LEXICON().
GLOBAL breshitInputWidgets IS LEXICON().
DECLARE FUNCTION resetBreshitDefaults {
    FOR key IN breshitDefaults:KEYS {
        SET userInputs[key] TO breshitDefaults[key].
    }.
    SET launchCountdown TO userInputs["launchCountdown"].

    FOR key IN breshitInputWidgets:KEYS {
        LOCAL widget IS breshitInputWidgets[key].
        IF key = "ignitionSync" OR key = "useRadarAlt" {
            SET widget:PRESSED TO userInputs[key].
        } ELSE {
            SET widget:TEXT TO "" + userInputs[key].
        }.
    }.
    IF breshitInputWidgets:HASKEY("boosterPreigniteMainThreshold") {
        SET breshitInputWidgets["boosterPreigniteMainThreshold"]:ENABLED TO userInputs["ignitionSync"].
    }.
}.

// Function to call the GUI with series-specific configuration. Called once after registering systems.
DECLARE FUNCTION startBreshitGui {
    DECLARE PARAMETER windowTitle IS shipName.
    DECLARE PARAMETER windowWidth IS guiConfig["width"].
    DECLARE PARAMETER refreshInterval IS guiConfig["refreshInterval"].

    resetBreshitDefaults().
    IF NOT flightData:HASKEY("launchGeo") {
        SET flightData["launchGeo"] TO SHIP:GEOPOSITION.
    }.

    // Define the tabs for the GUI window.
    LOCAL tabNames IS LIST("LAUNCH", "SCIENCE", "ENGINE", "RESOURCES", "SYSTEMS").
    createGuiWindow(windowTitle, windowWidth).
    LOCAL tabs IS guiAddTabs(guiState["window"], tabNames).

    // Build GUI windows into the relevant tabs.
    buildBreshitLaunchPanel(tabs["LAUNCH"]).
    buildSciencePanel(tabs["SCIENCE"]).
    buildBreshitEnginePanel(tabs["ENGINE"]).
    buildResourcesPanel(tabs["RESOURCES"]).
    buildBreshitSystemsPanel(tabs["SYSTEMS"]).

    // Run the GUI with its refresh and update cycle clock.
    showGui().
    refreshGui().
    armGuiRefresh(refreshInterval).

    // Output to log.
    logMessage("Breshit mission control GUI online.", "system", TRUE, FALSE, TRUE).
}.

// GUI PANELS
// --------------------------------------------------------------
DECLARE FUNCTION buildBreshitLaunchPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "LAUNCH CONTROL").
    guiAddButton(panel, "LAUNCH", {
        SET launchCountdown TO userInputs["launchCountdown"].
        commandLaunch().
    }).
    guiAddStatusRow(panel, "Mission Time", "berLaunchMet").
    guiAddStatusRow(panel, "Flight Status", "berLaunchPhase").
    guiAddStatusRow(panel, "Alert", "berLaunchAlert").
    guiSpacer(4, panel).
    guiAddHeading(panel, "DISTANCE").
    guiAddStatusRow(panel, "Altitude", "berLaunchAlt").
    guiAddStatusRow(panel, "Downrange", "berDownrange").
    guiAddStatusRow(panel, "Predicted Altitude", "berLaunchApo").
    guiSpacer(4, panel).
    guiAddHeading(panel, "CURRENT VELOCITY").
    guiAddStatusRow(panel, "Absolute Velocity (m/s)", "berLaunchVel").
    guiAddStatusRow(panel, "Imperial Speed (mph)", "berLaunchVmph").
    guiAddStatusRow(panel, "Metric Speed (km/h)", "berLaunchVkmh").
    guiSpacer(4, panel).
    guiAddHeading(panel, "FLIGHT DATA LOG").
    guiAddButton(panel, "Dump Flight Data To Log", outputFlightData@).

    

    registerUpdater({
        LOCAL boostersAttached IS SHIP:PARTSTAGGED(boosterType):LENGTH > 0.
        LOCAL alertText IS statusText("NOMINAL", "NOMINAL").

        IF taggedEnginesHaveFlameout(mainEngine) {
            SET alertText TO statusText("ENGINE FLAMEOUT", "CRITICAL").
        } ELSE IF flightData["phase"] = "main" AND boostersAttached {
            SET alertText TO statusText("BOOSTERS ATTACHED", "WARNING").
        } ELSE IF flightData["descentCaptured"] {
            SET alertText TO statusText("DESCENT", "WARNING").
        }.

        setWidgetText("berLaunchMet", formatTime(getLogTime(), "MS")).
        setWidgetText("berLaunchPhase", colorText(flightData["phase"]:TOUPPER(), guiTheme["accentColor"])).
        setWidgetText("berLaunchAlert", alertText).
        setWidgetText("berLaunchAlt", ROUND(ALTITUDE, 0) + " m").
        setWidgetText("berDownrange", ROUND(downrangeDistance(flightData["launchGeo"]) / 1000, 2) + "km.").
        setWidgetText("berLaunchVel", ROUND(SHIP:AIRSPEED, 2) + "m/s").
        setWidgetText("berLaunchVmph", ROUND(velocityMph(SHIP:AIRSPEED), 2) + "mph").
        setWidgetText("berLaunchVkmh", ROUND(velocityKmh(SHIP:AIRSPEED), 2) + "km/h").
        setWidgetText("berLaunchApo", ROUND(SHIP:APOAPSIS, 0) + " m").
        // setWidgetText("berLaunchVspd", ROUND(SHIP:VERTICALSPEED, 1) + " m/s").
        // setWidgetText("berLaunchSspd", ROUND(SHIP:VELOCITY:SURFACE:MAG, 1) + " m/s").
    }).

    RETURN panel.
}.

// DECLARE FUNCTION buildBreshitSciencePanel {
//     DECLARE PARAMETER parentBox IS guiState["window"].
//
//     LOCAL panel IS parentBox:ADDVBOX().
//     LOCAL variant IS shipVariant:TOUPPER().
//     guiAddHeading(panel, "SCIENCE SYSTEMS").
//
//     guiAddButton(panel, "Activate Science Systems", activateSystems@).
//     guiAddStatusRow(panel, "Primary Telemetry (AG1)", "berSciAg1").
//     guiAddStatusRow(panel, "Temperature Sensor (AG2)", "berSciAg2").
//     guiAddStatusRow(panel, "Pressure Sensor (AG3)", "berSciAg3").
//
//     registerUpdater({
//         setWidgetText("berSciAg1", CHOOSE statusText("ON", "NOMINAL") IF AG1 ELSE statusText("OFF", "WARNING")).
//
//         IF variant = "R1" {
//             setWidgetText("berSciAg2", CHOOSE statusText("ON", "NOMINAL") IF AG2 ELSE statusText("OFF", "WARNING")).
//             setWidgetText("berSciAg3", CHOOSE statusText("ON", "NOMINAL") IF AG3 ELSE statusText("OFF", "WARNING")).
//         } ELSE {
//             setWidgetText("berSciAg2", colorText("N/A", guiTheme["mutedColor"])).
//             setWidgetText("berSciAg3", colorText("N/A", guiTheme["mutedColor"])).
//         }.
//     }).
//
//     RETURN panel.
// }.

DECLARE FUNCTION buildBreshitEnginePanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "BOOSTERS").

    guiAddStatusRow(panel, "Attached", "berEngBoostAttached").
    guiAddStatusRow(panel, "Count", "berEngBoostCount").
    guiAddStatusRow(panel, "Output", "berEngBoostOut").
    LOCAL boosterDetachButton IS guiAddArmedAction(panel, "Emergency Booster Detach", {
        IF SHIP:PARTSTAGGED(boosterType):LENGTH > 0 {
            LOCAL detached IS jettisonTaggedBoosters(boosterDecouplerTag).
            IF detached > 0 {
                logMessage("Emergency booster decouplers activated: " + detached + ".", "warning", TRUE, TRUE, TRUE).
            } ELSE {
                logMessage("No tagged booster decouplers found.", "error", TRUE, FALSE, TRUE).
            }.
        }.
    }).

    guiSpacer(4, panel).
    guiAddHeading(panel, "MAIN ENGINE").
    guiAddStatusRow(panel, "Engine Tag", "berEngTag").
    guiAddStatusRow(panel, "Ignition", "berEngIgn").
    guiAddStatusRow(panel, "Flameout", "berEngFlame").
    guiAddStatusRow(panel, "Fuel", "berEngFuel").
    guiAddStatusRow(panel, "Output", "berEngMainOut").
    LOCAL mainIgniteButton IS guiAddArmedAction(panel, "Emergency Main Engine Ignite", {
        IF NOT taggedEnginesHaveIgnitionSignal(mainEngine) {
            FOR engine IN SHIP:PARTSTAGGED(mainEngine) {
                IF NOT engine:IGNITION {
                    engine:ACTIVATE().
                }.
            }.
            logMessage("Emergency main engine ignition command sent.", "warning", TRUE, TRUE, TRUE).
        }.
    }).
    guiAddArmedAction(panel, "Emergency Main Engine Shutdown", {
        LOCK THROTTLE TO 0.
        logMessage("Emergency main engine shutdown command sent (throttle to 0).", "warning", TRUE, TRUE, TRUE).
    }).

    registerUpdater({
        LOCAL boosterCount IS SHIP:PARTSTAGGED(boosterType):LENGTH.
        LOCAL boosterThrust IS getTaggedEngineThrust(boosterType).
        LOCAL boosterMax IS getTaggedEngineMaxThrust(boosterType).
        LOCAL boosterPct IS 0.
        LOCAL mainThrust IS getTaggedEngineThrust(mainEngine).
        LOCAL mainMax IS getTaggedEngineMaxThrust(mainEngine).
        LOCAL mainPct IS 0.
        SET boosterDetachButton:ENABLED TO boosterCount > 0.
        SET mainIgniteButton:ENABLED TO countTaggedEngines(mainEngine) > 0 AND NOT taggedEnginesHaveIgnitionSignal(mainEngine).

        IF boosterMax > 0 {
            SET boosterPct TO ROUND(100 * boosterThrust / boosterMax, 0).
        }.
        IF mainMax > 0 {
            SET mainPct TO ROUND(100 * mainThrust / mainMax, 0).
        }.


        setWidgetText("berEngBoostAttached", CHOOSE statusText("YES", "WARNING") IF boosterCount > 0 ELSE statusText("NO", "NOMINAL")).
        setWidgetText("berEngBoostCount", "" + boosterCount).
        setWidgetText("berEngBoostOut", boosterPct + " %").
        setWidgetText("berEngTag", mainEngine).
        setWidgetText("berEngIgn", CHOOSE statusText("ON", "NOMINAL") IF taggedEnginesHaveIgnitionSignal(mainEngine) ELSE statusText("OFF", "WARNING")).
        setWidgetText("berEngFlame", CHOOSE statusText("YES", "CRITICAL") IF taggedEnginesHaveFlameout(mainEngine) ELSE statusText("NO", "NOMINAL")).
        setWidgetText("berEngFuel", getResourcePercent("", fuelTank) + " %").
        setWidgetText("berEngMainOut", mainPct + " %").
    }).

    RETURN panel.
}.


DECLARE FUNCTION buildBreshitSystemsPanel {
    DECLARE PARAMETER parentBox IS guiState["window"].

    LOCAL panel IS parentBox:ADDVBOX().
    guiAddHeading(panel, "LAUNCH").
    SET breshitInputWidgets["launchCountdown"] TO guiAddNumberField(panel, "Countdown (s)", userInputs["launchCountdown"], {
        PARAMETER newValue.
        SET userInputs["launchCountdown"] TO MAX(0, ROUND(newValue, 0)).
        SET launchCountdown TO userInputs["launchCountdown"].
    }).
    guiSpacer(4, panel).

    guiAddHeading(panel, "BOOSTER / ENGINE").
    LOCAL preigniteField IS 0. // Set below; captured by the toggle so it can grey the field when ignition sync is off.
    SET breshitInputWidgets["ignitionSync"] TO guiAddToggle(panel, "Sync Main Ignition To Booster Fuel", userInputs["ignitionSync"], {
        PARAMETER isOn.
        SET userInputs["ignitionSync"] TO isOn.
        SET preigniteField:ENABLED TO isOn.
    }).
    SET preigniteField TO guiAddNumberField(panel, "Preignite Main Fuel %", userInputs["boosterPreigniteMainThreshold"], {
        PARAMETER newValue.
        SET userInputs["boosterPreigniteMainThreshold"] TO newValue.
    }).
    SET breshitInputWidgets["boosterPreigniteMainThreshold"] TO preigniteField.
    SET preigniteField:ENABLED TO userInputs["ignitionSync"]. // Only editable when main ignition is synced to booster fuel.
    SET breshitInputWidgets["separationBoosterPercentage"] TO guiAddNumberField(panel, "Booster Separation Fuel level (%)", userInputs["separationBoosterPercentage"], {
        PARAMETER newValue.
        SET userInputs["separationBoosterPercentage"] TO newValue.
    }).
    SET breshitInputWidgets["remainingFuelPercentage"] TO guiAddNumberField(panel, "Residual Cutoff Fuel %", userInputs["remainingFuelPercentage"], {
        PARAMETER newValue.
        SET userInputs["remainingFuelPercentage"] TO newValue.
    }).
    SET breshitInputWidgets["mainEngineStartThreshold"] TO guiAddNumberField(panel, "Ignition Grace (s)", userInputs["mainEngineStartThreshold"], {
        PARAMETER newValue.
        SET userInputs["mainEngineStartThreshold"] TO newValue.
    }).
    guiSpacer(4, panel).

    LOCAL manualDestructAllowed IS (userInputs["hasManualDestruct"] OR userInputs["hasAutoDestruct"]). // Auto-destruct implies the pilot can fire it too.

    guiAddHeading(panel, "ALARM").
    guiAddButton(panel, "Silence Alarm", stopAlarmSound@).
    guiSpacer(4, panel).
    guiAddArmedAction(panel, "Reset To Program Defaults", {
        resetBreshitDefaults().
        logMessage("Breshit system parameters reset to defaults.", "info", TRUE, FALSE, TRUE).
    }).
    IF manualDestructAllowed {
        guiSpacer(4, panel).
        guiAddHeading(panel, "DESTRUCT").

        IF userInputs["hasAutoDestruct"] {
            SET breshitInputWidgets["destructAlt"] TO guiAddNumberField(panel, "Destruct Alt (m)", userInputs["destructAlt"], {
                PARAMETER newValue.
                SET userInputs["destructAlt"] TO newValue.
            }).
            SET breshitInputWidgets["useRadarAlt"] TO guiAddToggle(panel, "Use Radar Alt", userInputs["useRadarAlt"], {
                PARAMETER isOn.
                SET userInputs["useRadarAlt"] TO isOn.
            }).
        }.
        guiAddArmedAction(panel, "SELF DESTRUCT", { requestSelfDestruct("MANUAL INPUT", 3). }).
    }.

    RETURN panel.
}.
