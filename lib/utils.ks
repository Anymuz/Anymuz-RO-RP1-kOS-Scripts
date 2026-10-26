DECLARE FUNCTION sumPartResource {
    DECLARE PARAMETER partTag.
    DECLARE PARAMETER resourceName.

    LOCAL total IS 0.
    LOCAL totalParts IS SHIP:PARTSTAGGED(partTag).

    FOR part IN totalParts {
        FOR resource IN part:RESOURCES {
            IF resource:NAME = resourceName {
                SET total TO total + resource:AMOUNT.
            }.
        }.
    }.

    RETURN total.
}.

DECLARE FUNCTION countBoosterIgnitions {
    DECLARE PARAMETER boosterTag IS "R103".

    LOCAL boosters IS SHIP:PARTSTAGGED(boosterTag).
    LOCAL ignitedCount IS 0.

    FOR booster IN boosters {
        IF booster:THRUST > 0 OR booster:IGNITION {
            SET ignitedCount TO ignitedCount + 1.
        }.
    }.

    RETURN ignitedCount.
}.

DECLARE FUNCTION outputFlightData {
    logMessage("Outputting flight data.", "info", TRUE, FALSE, FALSE).

    // Console output.
    PRINT " ".
    PRINT "--------------[FLIGHT DATA]--------------".
    PRINT "APOGEE ALTITUDE: " + ROUND(flightData["apogeeAlt"], 2) + "m.".
    PRINT "MAX VELOCITY: " + ROUND(flightData["maxVelocity"], 2) + "m/s".
    PRINT "ALTITUDE AT MAX VELOCITY: " + ROUND(flightData["maxVelocityAlt"], 2) + "m.".
    PRINT "VELOCITY AT APOGEE: " + ROUND(flightData["apogeeVelocity"], 2) + "m/s.".
    PRINT "MAX PREDICTED APOAPSIS: " + ROUND(flightData["maxApoapsis"], 2) + "m.".
    PRINT "ALTITUDE AT MAX PREDICTED APOAPSIS: " + ROUND(flightData["maxApoapsisAlt"], 2) + "m.".
    PRINT "---------------------------------------------".
    PRINT " ".

    // Log file output.
    writeLogFile("--------------------------------------------------").
    logMessage("apogee altitude: " + ROUND(flightData["apogeeAlt"], 2) + "m.", "data", TRUE, FALSE, FALSE).
    logMessage("max velocity: " + ROUND(flightData["maxVelocity"], 2) + "m/s.", "data", TRUE, FALSE, FALSE).
    logMessage("altitude at max velocity: " + ROUND(flightData["maxVelocityAlt"], 2) + "m.", "data", TRUE, FALSE, FALSE).
    logMessage("velocity at apogee: " + ROUND(flightData["apogeeVelocity"], 2) + "m/s.", "data", TRUE, FALSE, FALSE).
    logMessage("max predicted apoapsis: " + ROUND(flightData["maxApoapsis"], 2) + "m.", "data", TRUE, FALSE, FALSE).
    logMessage("altitude at max predicted apoapsis: " + ROUND(flightData["maxApoapsisAlt"], 2) + "m.", "data", TRUE, FALSE, FALSE).
    logMessage("flight phase: " + flightData["phase"] + ".", "data", TRUE, FALSE, FALSE).
    logMessage("descent captured: " + flightData["descentCaptured"] + ".", "data", TRUE, FALSE, FALSE).
    logMessage("flight time: " + ROUND(getLogTime(), 2) + "s.", "data", TRUE, FALSE, FALSE).
    logMessage("current altitude: " + ROUND(ALTITUDE, 2) + "m.", "data", TRUE, FALSE, FALSE).
    logMessage("current vertical speed: " + ROUND(SHIP:VERTICALSPEED, 2) + "m/s.", "data", TRUE, FALSE, FALSE).
    writeLogFile("--------------------------------------------------").

    logMessage("flight data output complete.", "info", TRUE, FALSE, FALSE).
}.