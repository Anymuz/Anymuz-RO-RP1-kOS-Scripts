DECLARE FUNCTION altitudeDetonation {
    logmessage("below destruct altitude.", "info", TRUE, FALSE, TRUE).
    logmessage("Vehicle will self-destruct imminently.", "warning", TRUE, FALSE, TRUE).
    playDetonationAlarm(3).
    WAIT 3.
    logMessage("Planned vehicle destruction occured.", "end", FALSE, FALSE, FALSE).
    ABORT ON.
}.

DECLARE FUNCTION armAltitudeDetonation {
    // destructAlt -> sea-level altitude threshold unless useRadarAlt = TRUE
    // useRadarAlt -> TRUE = use ALT:RADAR, FALSE = use ALTITUDE

    DECLARE PARAMETER destructAlt IS 40000.
    DECLARE PARAMETER useRadarAlt IS FALSE.

   // CLEARSCREEN.
    logMessage("Destruct system online.", "info", TRUE, FALSE, TRUE).
    logMessage("Destruct altitude: " + destructAlt + "m.", "info", TRUE, FALSE, TRUE).
   
    WHEN SHIP:VERTICALSPEED < -1 THEN {
        SET flightData["phase"] TO "descent".
        SET flightData["descentCaptured"] TO TRUE.
        logMessage("Descent detected. Self destruct armed.", "warning", TRUE, TRUE, TRUE).
        outputFlightData().
        
        IF useRadarAlt {
          WHEN ALT:RADAR < destructAlt THEN {
                altitudeDetonation().
            }.
        } ELSE {
            WHEN ALTITUDE < destructAlt THEN {
                altitudeDetonation().
            }.
        }.
    }.
}.

DECLARE FUNCTION selfDestruct {
    DECLARE PARAMETER reason IS "UNKNOWN".
    DECLARE PARAMETER fuzeTime IS 3. 

    logMessage("Self destruct initiated. Reason: " + reason, "fatal", FALSE, FALSE, FALSE).
    playDetonationAlarm(fuzeTime).
    WAIT fuzeTime.
    logMessage("Rapid vehicle disassembly has occurred.", "end", FALSE, FALSE, FALSE).
    ABORT ON.
}.