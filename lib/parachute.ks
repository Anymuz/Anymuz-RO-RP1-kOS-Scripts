// 0:/lib/parachute.ks
// Jettisons the chute fairing then deploys parachutes at a given altitude.
// Requires lib/logging.ks.

// Jettisons every part tagged fairingTag using the ProceduralFairingDecoupler
// "jettison" action (falls back to stock "jettison fairing" on ModuleProceduralFairing).
DECLARE FUNCTION jettisonChuteFairing {
    DECLARE PARAMETER fairingTag IS "CHUTE-CASE".

    LOCAL jettisoned IS 0.
    FOR fairing IN SHIP:PARTSTAGGED(fairingTag) {
        IF fairing:HASMODULE("ProceduralFairingDecoupler") {
            fairing:GETMODULE("ProceduralFairingDecoupler"):DOACTION("jettison fairing", TRUE).
            SET jettisoned TO jettisoned + 1.
        } ELSE IF fairing:HASMODULE("ModuleProceduralFairing") {
            fairing:GETMODULE("ModuleProceduralFairing"):DOACTION("jettison fairing", TRUE).
            SET jettisoned TO jettisoned + 1.
        }.
    }.
    logMessage("Chute fairing jettisoned (" + jettisoned + " parts).", "alert", TRUE, FALSE, TRUE).
}.

// Arms the parachute deploy trigger.
// Also dumps flight data at apogee, on chute deploy, and on touchdown so
// chute-recovered flights produce the same telemetry coverage as destruct flights.
//   chuteTag    -> VAB tag on chute parts.
//   deployAlt   -> altitude in metres to deploy at.
//   useRadarAlt -> TRUE = radar altitude, FALSE = sea-level altitude.
//   fairingTag  -> VAB tag on the chute fairing (jettisoned 1s before deploy).
DECLARE FUNCTION armParachute {
    DECLARE PARAMETER chuteTag IS "chute".
    DECLARE PARAMETER deployAlt IS 15000.
    DECLARE PARAMETER useRadarAlt IS TRUE.
    DECLARE PARAMETER fairingTag IS "CHUTE-CASE".

    logMessage("Chute deploy trigger set at " + deployAlt + "m.", "info", TRUE, FALSE, TRUE).

    // Apogee: first sustained negative vertical speed. Mirror armAltitudeDetonation
    // so chute flights also dump flight data at peak altitude.
    WHEN SHIP:VERTICALSPEED < -1 THEN {
        SET flightData["phase"] TO "descent".
        SET flightData["descentCaptured"] TO TRUE.
        logMessage("Descent detected. Apogee passed.", "alert", TRUE, TRUE, TRUE).
        outputFlightData().
    }.

    WHEN SHIP:VERTICALSPEED < 0 AND (CHOOSE ALT:RADAR IF useRadarAlt ELSE ALTITUDE) < deployAlt THEN {
        // Pop the fairing first so the chute has clear air.
        //jettisonChuteFairing(fairingTag).

        // Wait 1 second, then deploy the chute.
        LOCAL deployTime IS TIME:SECONDS + 1.
        WHEN TIME:SECONDS >= deployTime THEN {
            FOR parachute IN SHIP:PARTSTAGGED(chuteTag) {
                IF parachute:HASMODULE("RealChuteModule") {
                    parachute:GETMODULE("RealChuteModule"):DOACTION("deploy chute", TRUE).
                    //STAGE.
                }.
            }.
            SET flightData["phase"] TO "chute".
            logMessage("Parachutes deployed.", "alert", TRUE, TRUE, TRUE).
            outputFlightData().

            // Touchdown: ship reports LANDED or SPLASHED. Final flight data dump.
            WHEN SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" THEN {
                SET flightData["phase"] TO "landed".
                logMessage("Touchdown detected (" + SHIP:STATUS + ").", "alert", TRUE, TRUE, TRUE).
                outputFlightData().
            }.
        }.
    }.
}.
