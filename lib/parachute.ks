// 0:/lib/parachute.ks
// RealChute parachute arming helpers.
// Requires lib/logging.ks. RealChute deploys armed chutes when conditions are safe.
// Use printRealChuteInfo() in simulation to verify event and action names.

// =====================================================
// DEBUG / DISCOVERY
// =====================================================

DECLARE FUNCTION jettisonChuteFairing {
    DECLARE PARAMETER fairingTag IS "CHUTE-CASE".

    LOCAL fairings IS SHIP:PARTSTAGGED(fairingTag).
    LOCAL jettisoned IS 0.
    FOR fairing IN fairings {
        IF fairing:HASMODULE("ModuleDecouple") OR fairing:HASMODULE("ModuleAnchoredDecoupler") {
            fairing:DECOUPLE().
            SET jettisoned TO jettisoned + 1.
        }.
    }.

    IF jettisoned = 0 {
        logMessage("No tagged chute fairing decouplers found.", "warning", TRUE, FALSE, TRUE).
        RETURN FALSE.
    }.

    logMessage("Chute fairing jettison command sent.", "warning", TRUE, TRUE, TRUE).
    RETURN TRUE.
}.

// Print module, event, action, and field names for tagged chute parts.
DECLARE FUNCTION printRealChuteInfo {
    DECLARE PARAMETER chuteTag IS "chute".   // VAB tag on your chute parts.

    LOCAL chuteParts IS SHIP:PARTSTAGGED(chuteTag).

    IF chuteParts:LENGTH = 0 {
        logMessage("printRealChuteInfo: no parts tagged '" + chuteTag + "' found.", "warning", TRUE, FALSE, TRUE).
        RETURN.
    }.

    FOR p IN chuteParts {
        // Print part name and tag so you can map output back to the VAB.
        PRINT "Part: " + p:NAME + " / tag: " + p:TAG.
        PRINT "  Modules: " + p:MODULES.

        IF p:HASMODULE("RealChuteModule") {
            LOCAL m IS p:GETMODULE("RealChuteModule").
            // Copy the event/action names exactly into the parameters below.
            PRINT "  --- RealChuteModule ---".
            PRINT "  Fields:  " + m:ALLFIELDNAMES.
            PRINT "  Events:  " + m:ALLEVENTNAMES.
            PRINT "  Actions: " + m:ALLACTIONNAMES.
        } ELSE {
            PRINT "  (no RealChuteModule found on this part)".
        }.
    }.
}.

// =====================================================
// ARMING
// =====================================================
// Arms all RealChute parachutes on parts tagged chuteTag.
//   chuteTag     -> VAB tag on your chute parts (default "chute").
//   armEventName -> right-click menu event name (verify with printRealChuteInfo).
//   armActionName-> fallback action group name if the event is not visible.
// Returns TRUE if all chutes were successfully armed.
DECLARE FUNCTION armRealChutes {
    DECLARE PARAMETER chuteTag IS "chute".
    // armEventName / armActionName: get these by running printRealChuteInfo("chute")
    // in simulation. Copy the string exactly from the "Events" or "Actions" line.
    // RealChute defaults; override for other versions.
    DECLARE PARAMETER armEventName IS "Arm parachute".
    DECLARE PARAMETER armActionName IS "Arm parachute".

    LOCAL chuteParts IS SHIP:PARTSTAGGED(chuteTag).

    IF chuteParts:LENGTH = 0 {
        logMessage("armRealChutes: no parts tagged '" + chuteTag + "' found.", "warning", TRUE, FALSE, TRUE).
        RETURN FALSE.
    }.

    LOCAL armed IS 0.  // Running count of successfully armed chutes.

    FOR p IN chuteParts {
        IF p:HASMODULE("RealChuteModule") {
            LOCAL m IS p:GETMODULE("RealChuteModule").

                    // Prefer the event; use the action if the event is unavailable.
            IF m:HASEVENT(armEventName) {
                m:DOEVENT(armEventName).
                SET armed TO armed + 1.
                logMessage("Parachute armed (event) on '" + p:TAG + "'.", "info", TRUE, FALSE, TRUE).
            } ELSE IF m:HASACTION(armActionName) {
                m:DOACTION(armActionName, TRUE).
                SET armed TO armed + 1.
                logMessage("Parachute armed (action) on '" + p:TAG + "'.", "info", TRUE, FALSE, TRUE).
            } ELSE {
                // Check event/action names with printRealChuteInfo().
                logMessage("Arm event/action not found on '" + p:TAG + "'. Run printRealChuteInfo() to check names.", "warning", TRUE, FALSE, TRUE).
            }.
        } ELSE {
            logMessage("Part '" + p:TAG + "' has no RealChuteModule.", "warning", TRUE, FALSE, TRUE).
        }.
    }.

    logMessage("Parachutes armed: " + armed + "/" + chuteParts:LENGTH + ".", "alert", TRUE, FALSE, TRUE).
    RETURN armed = chuteParts:LENGTH.
}.

// Arm tagged chutes when descending through armAlt.
//   armAlt       -> altitude in metres at which to arm (ASL unless useRadarAlt).
//   chuteTag     -> VAB tag on your chute parts.
//   armEventName -> event name from printRealChuteInfo().
//   armActionName-> fallback action name from printRealChuteInfo().
//   useRadarAlt  -> TRUE = use radar (ground) altitude, FALSE = use sea-level altitude.
DECLARE FUNCTION armChuteAtAltitude {
    DECLARE PARAMETER armAlt IS 8000.
    DECLARE PARAMETER chuteTag IS "chute".
    // RealChute defaults; override for other versions.
    DECLARE PARAMETER armEventName IS "Arm parachute".
    DECLARE PARAMETER armActionName IS "Arm parachute".
    DECLARE PARAMETER useRadarAlt IS FALSE.

    logMessage("Chute arm trigger set: descend through " + armAlt + "m.", "info", TRUE, FALSE, TRUE).

    // The trigger expires after arming because the altitude branch does not PRESERVE.
    WHEN SHIP:VERTICALSPEED < 0 THEN {

        // Pick altitude source based on the useRadarAlt flag.
        LOCAL currentAlt IS ALTITUDE.
        IF useRadarAlt { SET currentAlt TO ALT:RADAR. }.

        IF currentAlt < armAlt {
            // Threshold crossed - arm now and let the trigger expire.
            logMessage("Arm altitude reached (" + ROUND(currentAlt) + "m). Arming parachutes.", "alert", TRUE, TRUE, TRUE).
            armRealChutes(chuteTag, armEventName, armActionName).
            // No PRESERVE - trigger fires once then stops.
        } ELSE {
            // Not yet below armAlt - keep watching.
            PRESERVE.
        }.
    }.
}.
