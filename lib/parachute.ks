// EXPLAINATION
// * Jettisons the chute fairing then deploys parachutes at a given altitude
// --------------------------------------------------------------

// FUNCTIONS
// Jettisons the fairing on tagged parts
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

// Arms chute deploy and flight data dumps
DECLARE FUNCTION armParachute {
    DECLARE PARAMETER chuteTag IS "chute".
    DECLARE PARAMETER deployAlt IS 15000.   // metres
    DECLARE PARAMETER useRadarAlt IS TRUE.
    DECLARE PARAMETER fairingTag IS "CHUTE-CASE".

    logMessage("Chute deploy trigger set at " + deployAlt + "m.", "info", TRUE, FALSE, TRUE).

    // Apogee passed, dumps flight data
    WHEN SHIP:VERTICALSPEED < -1 THEN {
        SET flightData["phase"] TO "descent".
        SET flightData["descentCaptured"] TO TRUE.
        logMessage("Descent detected. Apogee passed.", "alert", TRUE, TRUE, TRUE).
        outputFlightData().
    }.

    WHEN SHIP:VERTICALSPEED < 0 AND (CHOOSE ALT:RADAR IF useRadarAlt ELSE ALTITUDE) < deployAlt THEN {
        // Fairing first so the chute has clear air
        //jettisonChuteFairing(fairingTag).

        // Deploys 1s later
        LOCAL deployTime IS TIME:SECONDS + 1.
        WHEN TIME:SECONDS >= deployTime THEN {
            FOR parachute IN SHIP:PARTSTAGGED(chuteTag) {
                IF parachute:HASMODULE("RealChuteModule") {
                    parachute:GETMODULE("RealChuteModule"):DOACTION("deploy chute", TRUE).
                }.
            }.
            SET flightData["phase"] TO "chute".
            logMessage("Parachutes deployed.", "alert", TRUE, TRUE, TRUE).
            //outputFlightData().

            // Touchdown, final flight data dump
            WHEN SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" THEN {
                SET flightData["phase"] TO "landed".
                logMessage("Touchdown detected (" + SHIP:STATUS + ").", "alert", TRUE, TRUE, TRUE).
                outputFlightData().
            }.
        }.
    }.
}.
// --------------------------------------------------------------