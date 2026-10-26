// EXPLAINATION
// * Controls the safety auto-destruct feature on single-use rockets.
// --------------------------------------------------------------

// FUNCTIONS
DECLARE FUNCTION altitudeDetonation {
    logmessage("below destruct altitude.", "info", TRUE, FALSE, TRUE).
    logmessage("Vehicle will self-destruct imminently.", "warning", TRUE, FALSE, TRUE).
    playDetonationAlarm(3).
    WAIT 3.
    logMessage("Planned vehicle destruction occured.", "end", FALSE, FALSE, FALSE).
    ABORT ON.
}. // Auto detonate before hitting ground

DECLARE FUNCTION armAltitudeDetonation {
    // altGetter   -> delegate returning the live destruct altitude (m); re-read each tick so GUI edits apply mid-flight.
    // radarGetter -> delegate returning TRUE for ALT:RADAR, FALSE for sea-level ALTITUDE.
    DECLARE PARAMETER altGetter.
    DECLARE PARAMETER radarGetter.

    logMessage("Destruct system online.", "info", TRUE, FALSE, TRUE).
    logMessage("Destruct altitude: " + altGetter:CALL() + "m.", "info", TRUE, FALSE, TRUE).

    WHEN SHIP:VERTICALSPEED < -1 THEN {
        SET flightData["phase"] TO "descent".
        SET flightData["descentCaptured"] TO TRUE.
        logMessage("Descent detected. Self destruct armed.", "warning", TRUE, TRUE, TRUE).
        outputFlightData().

        // Single live trigger: mode and threshold are read each tick from the getters.
        WHEN (CHOOSE ALT:RADAR IF radarGetter:CALL() ELSE ALTITUDE) < altGetter:CALL() THEN {
            IF systemManual("Destruct") {
                PRESERVE. // Pilot holds control - keep watching in case they hand it back.
            } ELSE {
                altitudeDetonation().
            }.
        }.
    }.
}. // Arms and waits to detect rocket falling

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