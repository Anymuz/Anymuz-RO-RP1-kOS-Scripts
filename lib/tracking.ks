// EXPLAINATION
// * For tracking and monitoring flight and engine
// --------------------------------------------------------------

// FUNCTIONS
// Constantly storing flight statistics throughout the flight in universal flightData lexicon.
DECLARE FUNCTION trackFlightStats {
    // UNTIL flightData["descentCaptured"] {
    WHEN TRUE THEN  {
        IF SHIP:VELOCITY:SURFACE:MAG > flightData["maxVelocity"] {
            SET flightData["maxVelocity"] TO SHIP:VELOCITY:SURFACE:MAG.
            SET flightData["maxVelocityAlt"] TO ALTITUDE.
        }.
        IF ALTITUDE > flightData["apogeeAlt"] {
            SET flightData["apogeeAlt"] TO ALTITUDE.
            SET flightData["apogeeVelocity"] TO SHIP:VELOCITY:SURFACE:MAG.
        }.
        IF SHIP:APOAPSIS > flightData["maxApoapsis"] {
            SET flightData["maxApoapsis"] TO SHIP:APOAPSIS.
            SET flightData["maxApoapsisAlt"] TO ALTITUDE.
        }.
        IF SHIP:VERTICALSPEED < 0 AND NOT flightData["descentCaptured"] {
            SET flightData["descentCaptured"] TO TRUE.
            SET flightData["apogeeAlt"] TO ALTITUDE.
            SET flightData["apogeeVelocity"] TO SHIP:VELOCITY:SURFACE:MAG.
        }.
        // WAIT 0.1.
        PRESERVE.
    }.
}.

// Engine performance and status monitoring system, correct parameters required for safe monitoring.
DECLARE FUNCTION monitorEngines {
    DECLARE PARAMETER engineTag IS "U-1250".
    DECLARE PARAMETER remainingFuelPercentage IS 2. // Expected tank fill % remaining at natural engine cutoff.
    DECLARE PARAMETER fuelTank IS "HPSFT".
    DECLARE PARAMETER spoolupTime IS 0.13.

    // Alarm trips for the monitoring system
    LOCAL engineWasRunning IS FALSE.
    LOCAL ignitionFailureReported IS FALSE.
    LOCAL engineFailureReported IS FALSE.
    LOCAL flameoutReported IS FALSE.
    LOCAL thrustLossReported IS FALSE.
    LOCAL engineOfflineReported IS FALSE.

    LOCAL startupGrace IS MAX(spoolupTime, 0.7).// Minimum forthrust buildup, prevents false reports failure detection.
    LOCAL thrustSeen IS FALSE.
    LOCAL thrustStartTime IS 0.

    WHEN TRUE THEN {
        LOCAL engines IS SHIP:PARTSTAGGED(engineTag). // BOOLEAN value foto determine ignited engines
        FOR engine IN engines {
            // Fuel Check
            LOCAL hasFuel IS FALSE.
            IF getResourcePercent("", fuelTank) > remainingFuelPercentage {
                SET hasFuel TO TRUE.
            }.
            IF engine:THRUST > 0 {
                SET engineWasRunning TO TRUE.

                IF NOT thrustSeen {
                    SET thrustSeen TO TRUE.
                    SET thrustStartTime TO TIME:SECONDS.
                }.
            }.

            // Ignition failure
            IF flightData["phase"] = "main" AND hasFuel AND engine:THRUST = 0 AND NOT (engineWasRunning OR ignitionFailureReported) {
                logMessage("Engine ignition failure detected.", "critical", TRUE, TRUE, TRUE).
                playEngineFailureAlarm().
                SET ignitionFailureReported TO TRUE.
            }.

            // Complete failure
            IF engineWasRunning AND hasFuel AND engine:THRUST = 0 AND NOT engineFailureReported {
                logMessage("Engine failure detected: no engine output.", "critical", TRUE, TRUE, TRUE).
                playEngineFailureAlarm().
                SET engineFailureReported TO TRUE.
            }.

            // Flameout failure
            IF engine:FLAMEOUT AND NOT flameoutReported {
                IF hasFuel {
                    logMessage("Engine flameout detected despite fuel availability.", "critical", TRUE, TRUE, TRUE).
                    playEngineFailureAlarm().
                } ELSE {
                    logMessage("Engine flameout detected due to fuel depletion.", "alert", TRUE, TRUE, TRUE).
                }.
                SET flameoutReported TO TRUE.
            }.

            // Thrust loss failure (below 50%)
            LOCAL thrustReady IS thrustSeen AND TIME:SECONDS > thrustStartTime + startupGrace.
            LOCAL thrustLow IS engine:MAXTHRUST > 0 AND engine:THRUST < (engine:MAXTHRUST * 0.85) AND engine:THRUST > 0.
            IF hasFuel AND thrustReady AND thrustLow AND NOT thrustLossReported {
                logMessage("Engine thrust loss detected: " + ROUND(engine:THRUST, 2) + " / " + ROUND(engine:MAXTHRUST, 2) + ".", "alert", TRUE, FALSE, TRUE).
                logMessage("Engine output: " + ROUND((engine:THRUST / engine:MAXTHRUST) * 100, 2) + "%.", "alert", TRUE, FALSE, TRUE).
                logMessage("Possible engine malfunction detected.", "warning", TRUE, TRUE, TRUE).
                playEngineFailureAlarm(3).
                SET thrustLossReported TO TRUE.
            }.

            // Inform engine offline if failures that suggest engine is not producing thrust.
            IF (ignitionFailureReported OR engineFailureReported OR flameoutReported) AND NOT engineOfflineReported {
                logMessage("Main engine offline.", "offline", TRUE, FALSE, TRUE).
                SET engineOfflineReported TO TRUE.
            }.
        }.

        WAIT 0.1.
        PRESERVE.
    }.
}.
// --------------------------------------------------------------