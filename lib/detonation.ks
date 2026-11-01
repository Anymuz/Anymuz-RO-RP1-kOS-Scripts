// EXPLAINATION
// * Controls the safety auto-destruct feature on single-use rockets.
// --------------------------------------------------------------

// FUNCTIONS
// Auto detonation sequence
DECLARE FUNCTION altitudeDetonation {
    logmessage("below destruct altitude.", "info", TRUE, FALSE, TRUE).
    logmessage("Vehicle will self-destruct imminently.", "warning", TRUE, FALSE, TRUE).
    playDetonationAlarm(3).
    WAIT 3.
    logMessage("Planned vehicle destruction occured.", "end", FALSE, FALSE, FALSE).
    ABORT ON.
}. // Auto detonate before hitting ground

// Arms destruct below altitude
DECLARE FUNCTION armAltitudeDetonation {
    // altGetter -> delegate for destruct altitude (m), radarGetter -> TRUE for radar altitude
    DECLARE PARAMETER altGetter.
    DECLARE PARAMETER radarGetter.

    logMessage("Destruct system online.", "info", TRUE, FALSE, TRUE).
    logMessage("Destruct altitude: " + altGetter:CALL() + "m.", "info", TRUE, FALSE, TRUE).

    WHEN SHIP:VERTICALSPEED < -1 THEN {
        SET flightData["phase"] TO "descent".
        SET flightData["descentCaptured"] TO TRUE.
        logMessage("Descent detected. Self destruct armed.", "warning", TRUE, TRUE, TRUE).
        outputFlightData().

        // Mode and altitude re-read each tick
        WHEN (CHOOSE ALT:RADAR IF radarGetter:CALL() ELSE ALTITUDE) < altGetter:CALL() THEN {
            IF systemManual("Destruct") {
                PRESERVE. // Pilot has control
            } ELSE {
                altitudeDetonation().
            }.
        }.
    }.
}. // Arms and waits to detect rocket falling

// Destruct after fuze time
DECLARE FUNCTION selfDestruct {
    DECLARE PARAMETER reason IS "UNKNOWN".
    DECLARE PARAMETER fuzeTime IS 3. 

    logMessage("Self destruct initiated | Reason: " + reason + " | Fuze time: " + fuzeTime + "s.", "fatal", FALSE, FALSE, FALSE).
    playDetonationAlarm(fuzeTime).
    WAIT fuzeTime.
    logMessage("Rapid vehicle disassembly has occurred.", "end", FALSE, FALSE, FALSE).
    ABORT ON.
}. // Does the self destruction.
// --------------------------------------------------------------