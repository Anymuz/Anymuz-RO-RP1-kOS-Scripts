// =====================================================
// INITIAL DOUBLE-IPHASE GNITION LAUNCH FUNCTIONS
// =====================================================
DECLARE FUNCTION initializeLaunch {
    logMessage("Launch sequence standby. Press any key to proceed.", "standby", TRUE, FALSE, TRUE).
    TERMINAL:INPUT:GETCHAR().
    WAIT 0.05.
    CLEARSCREEN.
    logMessage("User input detected", "action", TRUE, FALSE, FALSE).
    logMessage("Launch sequence now commencing.", "alert", TRUE, TRUE, TRUE).
    WAIT 1.
}.

DECLARE FUNCTION countdownLaunch {
    DECLARE PARAMETER seconds IS 10.
    CLEARSCREEN.
    logMessage("The launch can be aborted safely with CTRL+C.", "INFO", TRUE, FALSE, TRUE).
    logMessage("Doing so deactivates computer. 'REBOOT.' to restart.", "INFO", TRUE, FALSE, TRUE).
    skipLine().
    PRINT "                                                                                                                                " AT (0,4).
    PRINT  "[LAUNCH] COUNTDOWN SET TO: [" + seconds + "s]." AT(0,5).
    logMessage("Countdown set to: " + seconds + " seconds. Begining countdown.", "launch", TRUE, FALSE, FALSE).
    logMessage("Playing countdown audio.", "audio", TRUE, FALSE, FALSE).
    FROM { LOCAL count IS 0 - seconds. } UNTIL count = 0 STEP { SET count TO count + 1. } DO {
        PRINT " " AT(0,6).
        PRINT "[LAUNCH] T: " + count + "s                                               " AT(0,7).
        playCountdownSound().
        WAIT 1.
        PRINT "                                                                                                                          " AT(0,8).
    }.
    logMessage("Countdown complete.", "launch", TRUE, FALSE, FALSE).
}.

// Original simple launch function., just stages and puts logs to launchmode..
// Keeping this this for use case ordinary rockets or booster-first designs.
DECLARE FUNCTION launchShip {
    SET flightData["phase"] TO "prelaunch".
    LOCK THROTTLE TO 1.
    LOCK STEERING TO UP.

    setLogToLaunchTime("MS", TRUE).

    wait 0.1.
    CLEARSCREEN.
    logMessage("Booster ignition.", "active", TRUE, FALSE, TRUE).
    
    wait 0.1.
    STAGE.
    playLaunchSound().
    logMessage("Liftoff! Launch completed.", "launch", TRUE, FALSE, TRUE).
}.

// =====================================================
// CLAMP-HELD ENGINE LAUNCH FUNCTIONS
// =====================================================

DECLARE FUNCTION getTaggedEngineThrust {
    DECLARE PARAMETER engineTag IS "U-1250".

    LOCAL totalThrust IS 0.
    LOCAL engines IS SHIP:PARTSTAGGED(engineTag).

    FOR engine IN engines {
        SET totalThrust TO totalThrust + engine:THRUST.
    }.

    RETURN totalThrust.
}.


DECLARE FUNCTION getTaggedEngineMaxThrust {
    DECLARE PARAMETER engineTag IS "U-1250".

    LOCAL totalMaxThrust IS 0.
    LOCAL engines IS SHIP:PARTSTAGGED(engineTag).

    FOR engine IN engines {
        SET totalMaxThrust TO totalMaxThrust + engine:MAXTHRUST.
    }.

    RETURN totalMaxThrust.
}.


DECLARE FUNCTION getTaggedEngineTWR {
    DECLARE PARAMETER engineTag IS "U-1250".

    IF SHIP:MASS <= 0 {
        RETURN 0.
    }.

    RETURN getTaggedEngineThrust(engineTag) / (SHIP:MASS * CONSTANT:G0).
}.


DECLARE FUNCTION taggedEnginesHaveFlameout {
    DECLARE PARAMETER engineTag IS "U-1250".

    LOCAL engines IS SHIP:PARTSTAGGED(engineTag).

    FOR engine IN engines {
        IF engine:FLAMEOUT {
            RETURN TRUE.
        }.
    }.

    RETURN FALSE.
}.


DECLARE FUNCTION taggedEnginesHaveIgnitionSignal {
    DECLARE PARAMETER engineTag IS "U-1250".

    LOCAL engines IS SHIP:PARTSTAGGED(engineTag).

    FOR engine IN engines {
        IF engine:IGNITION {
            RETURN TRUE.
        }.
    }.

    RETURN FALSE.
}.


DECLARE FUNCTION countTaggedEngines {
    DECLARE PARAMETER engineTag IS "U-1250".

    RETURN SHIP:PARTSTAGGED(engineTag):LENGTH.
}.


// This is a light check used during clamp-held ignition.
// It checks for obvious failures before release.
DECLARE FUNCTION checkClampHeldEngineHealth {
    DECLARE PARAMETER engineTag IS "U-1250".
    DECLARE PARAMETER minimumThrust IS 0.1.

    IF countTaggedEngines(engineTag) <= 0 {
        logMessage("Prelaunch engine failure: no engines found with tag: " + engineTag + ".", "critical", TRUE, TRUE, TRUE).
        RETURN FALSE.
    }.

    IF taggedEnginesHaveFlameout(engineTag) {
        logMessage("Prelaunch engine failure: flameout detected while clamped.", "critical", TRUE, TRUE, TRUE).
        RETURN FALSE.
    }.

    LOCAL currentThrust IS getTaggedEngineThrust(engineTag).

    IF currentThrust <= minimumThrust {
        // This is not immediately fatal because the engine may still be spooling up.
        RETURN TRUE.
    }.

    RETURN TRUE.
}.


// Waits until engine is safe to release from launch clamp.
// It confirms:
// - engine exists
// - no flameout
// - TWR reaches target
// - TWR remains stable briefly
// - thrust is not decaying
// - optional propellant drain is confirmed
DECLARE FUNCTION waitForClampReleaseReadiness {
    DECLARE PARAMETER engineTag IS "U-1250".
    DECLARE PARAMETER fuelTankTag IS "HPSFT".
    DECLARE PARAMETER propellant IS "Kerosene".
    DECLARE PARAMETER oxidizer IS "AK20".
    DECLARE PARAMETER releaseTWR IS 1.3.
    DECLARE PARAMETER maxClampWait IS 15.
    DECLARE PARAMETER stableHoldTime IS 0.5.
    DECLARE PARAMETER maxTWRDrop IS 0.05.
    DECLARE PARAMETER requirePropellantDrain IS TRUE.
    DECLARE PARAMETER resourceCheckDelay IS 0.5.

    LOCAL startTime IS TIME:SECONDS.
    LOCAL stableStart IS -1.
    LOCAL previousTWR IS 0.
    LOCAL propellantDrainConfirmed IS FALSE.
    LOCAL oxidizerDrainConfirmed IS FALSE.

    LOCAL startingPropellant IS sumPartResource(fuelTankTag, propellant).
    LOCAL startingOxidizer IS sumPartResource(fuelTankTag, oxidizer).

    logMessage("Monitoring clamp-held engine start.", "launch", TRUE, FALSE, TRUE).
    logMessage("Clamp release target TWR: " + releaseTWR + ".", "launch", TRUE, FALSE, TRUE).
    logMessage("Maximum clamp wait: " + maxClampWait + " seconds.", "launch", TRUE, FALSE, TRUE).

    UNTIL TIME:SECONDS > startTime + maxClampWait {

        LOCAL currentTWR IS getTaggedEngineTWR(engineTag).
        LOCAL currentThrust IS getTaggedEngineThrust(engineTag).
        LOCAL currentPropellant IS sumPartResource(fuelTankTag, propellant).
        LOCAL currentOxidizer IS sumPartResource(fuelTankTag, oxidizer).
        LOCAL elapsed IS TIME:SECONDS - startTime.

        PRINT "CLAMP TWR: " + ROUND(currentTWR, 3) + " / " + releaseTWR + "      " AT(0, 5).
        PRINT "THRUST:    " + ROUND(currentThrust, 2) + " kN      " AT(0, 6).

        IF NOT checkClampHeldEngineHealth(engineTag, 0.1) {
            logMessage("Clamp-held engine health check failed.", "critical", TRUE, TRUE, TRUE).
            RETURN FALSE.
        }.

        IF currentPropellant < startingPropellant {
            SET propellantDrainConfirmed TO TRUE.
        }.

        IF currentOxidizer < startingOxidizer {
            SET oxidizerDrainConfirmed TO TRUE.
        }.

        IF elapsed > resourceCheckDelay AND requirePropellantDrain {
            IF currentThrust > 0.1 {
                IF NOT propellantDrainConfirmed OR NOT oxidizerDrainConfirmed {
                    logMessage("Prelaunch engine failure: thrust detected but propellant drain not confirmed.", "critical", TRUE, TRUE, TRUE).
                    logMessage("Check fuel tank tag or resource names if this is a false abort.", "warning", TRUE, FALSE, TRUE).
                    RETURN FALSE.
                }.
            }.
        }.

        IF currentTWR < previousTWR - maxTWRDrop {
            logMessage("Prelaunch thrust decay detected.", "critical", TRUE, TRUE, TRUE).
            logMessage("Previous TWR: " + ROUND(previousTWR, 3) + ". Current TWR: " + ROUND(currentTWR, 3) + ".", "critical", TRUE, FALSE, TRUE).
            RETURN FALSE.
        }.

        IF currentTWR >= releaseTWR {

            IF stableStart < 0 {
                SET stableStart TO TIME:SECONDS.
                logMessage("Release TWR reached. Verifying stable thrust.", "launch", TRUE, FALSE, TRUE).
            }.

            IF TIME:SECONDS >= stableStart + stableHoldTime {
                logMessage("Stable clamp-release TWR confirmed.", "launch", TRUE, FALSE, TRUE).
                logMessage("Final clamp-held TWR: " + ROUND(currentTWR, 3) + ".", "launch", TRUE, FALSE, TRUE).
                RETURN TRUE.
            }.

        } ELSE {
            SET stableStart TO -1.
        }.

        SET previousTWR TO currentTWR.

        WAIT 0.1.
    }.

    logMessage("Clamp release aborted: engine failed to reach required TWR before timeout.", "critical", TRUE, TRUE, TRUE).
    logMessage("Final TWR: " + ROUND(getTaggedEngineTWR(engineTag), 3) + ".", "critical", TRUE, FALSE, TRUE).

    RETURN FALSE.
}.


// Main launch function for downrange rockets with no booster stage.
// Stage order must be:
// First STAGE call  = engine ignition
// Second STAGE call = launch clamp release
DECLARE FUNCTION launchShipClampTWR {
    DECLARE PARAMETER engineTag IS "U-1250".
    DECLARE PARAMETER fuelTankTag IS "HPSFT".
    DECLARE PARAMETER propellant IS "Kerosene".
    DECLARE PARAMETER oxidizer IS "AK20".
    DECLARE PARAMETER releaseTWR IS 1.3.
    DECLARE PARAMETER maxClampWait IS 15.
    DECLARE PARAMETER launchAzimuth IS 90.
    DECLARE PARAMETER requirePropellantDrain IS TRUE.

    SET flightData["phase"] TO "prelaunch".

    LOCK THROTTLE TO 1.
    LOCK STEERING TO HEADING(launchAzimuth, 90).

    setLogToLaunchTime("MS", TRUE).

    WAIT 0.1.
    CLEARSCREEN.

    logMessage("Main engine ignition command sent.", "active", TRUE, FALSE, TRUE).

    // First STAGE call should ignite the engine.
    STAGE.
    playLaunchSound().

    IF NOT waitForClampReleaseReadiness(
        engineTag,
        fuelTankTag,
        propellant,
        oxidizer,
        releaseTWR,
        maxClampWait,
        0.5,
        0.05,
        requirePropellantDrain,
        0.5
    ) {
        logMessage("Launch aborted while held on clamp.", "abort", TRUE, TRUE, TRUE).
        LOCK THROTTLE TO 0.
        SET flightData["phase"] TO "aborted".
        RETURN FALSE.
    }.

    logMessage("Releasing launch clamp.", "launch", TRUE, FALSE, TRUE).

    // Second STAGE call should release the clamp.
    STAGE.

    SET flightData["phase"] TO "main".

    logMessage("Liftoff. Launch clamp released.", "launch", TRUE, FALSE, TRUE).

    RETURN TRUE.
}.