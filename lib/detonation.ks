RUNONCEPATH("0:/lib/gui/guiAutomation.ks").

GLOBAL selfDestructRequest IS LEXICON(
    "requested", FALSE,
    "active", FALSE,
    "reason", "",
    "fuzeTime", 3,
    "deadline", 0
).

DECLARE FUNCTION requestSelfDestruct {
    DECLARE PARAMETER reason IS "GUI COMMAND".
    DECLARE PARAMETER fuzeTime IS 3.

    IF selfDestructRequest["requested"] OR selfDestructRequest["active"] {
        RETURN.
    }.

    SET selfDestructRequest["reason"] TO reason.
    SET selfDestructRequest["fuzeTime"] TO fuzeTime.
    SET selfDestructRequest["requested"] TO TRUE.
}.

WHEN selfDestructRequest["requested"] THEN {
    SET selfDestructRequest["requested"] TO FALSE.
    SET selfDestructRequest["active"] TO TRUE.
    SET selfDestructRequest["deadline"] TO TIME:SECONDS + selfDestructRequest["fuzeTime"].
    logMessage("Self destruct initiated | Reason: " + selfDestructRequest["reason"] + " | Fuze time: " + selfDestructRequest["fuzeTime"] + "s.", "fatal", FALSE, FALSE, FALSE).
    playDetonationAlarm(selfDestructRequest["fuzeTime"]).
    PRESERVE.
}.

WHEN selfDestructRequest["active"] AND TIME:SECONDS >= selfDestructRequest["deadline"] THEN {
    SET selfDestructRequest["active"] TO FALSE.
    logMessage("Rapid vehicle disassembly has occurred.", "end", FALSE, FALSE, FALSE).
    ABORT ON.
}.

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
    DECLARE PARAMETER systemName IS "Destruct".

   // CLEARSCREEN.
    logMessage("Destruct system online.", "info", TRUE, FALSE, TRUE).
    logMessage("Destruct altitude: " + destructAlt + "m.", "info", TRUE, FALSE, TRUE).

    WHEN SHIP:VERTICALSPEED < -1 THEN {
        SET flightData["phase"] TO "descent".
        SET flightData["descentCaptured"] TO TRUE.
        logMessage("Descent detected. Self destruct armed.", "warning", TRUE, TRUE, TRUE).
        outputFlightData().

        IF useRadarAlt {
          WHEN NOT systemManual(systemName) AND ALT:RADAR < destructAlt THEN {
                altitudeDetonation().
            }.
        } ELSE {
            WHEN NOT systemManual(systemName) AND ALTITUDE < destructAlt THEN {
                altitudeDetonation().
            }.
        }.
    }.
}.

DECLARE FUNCTION selfDestruct {
    DECLARE PARAMETER reason IS "UNKNOWN".
    DECLARE PARAMETER fuzeTime IS 3.

    logMessage("Self destruct initiated | Reason: " + reason + " | Fuze time: " + fuzeTime + "s.", "fatal", FALSE, FALSE, FALSE).
    playDetonationAlarm(fuzeTime).
    WAIT fuzeTime.
    logMessage("Rapid vehicle disassembly has occurred.", "end", FALSE, FALSE, FALSE).
    ABORT ON.
}.