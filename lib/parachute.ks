// 0:/lib/parachute.ks
// RealChute parachute arming and deployment helpers.
// All functions are pure helpers with no top-level side effects.

// Prints all discovered module names, events, actions, and fields for every
// part carrying RealChuteModule. Call this once in simulation to get the
// exact names your RealChute version exposes.
DECLARE FUNCTION printRealChuteInfo {
    DECLARE PARAMETER chuteTag IS "chute".

    LOCAL chuteParts IS SHIP:PARTSTAGGED(chuteTag).

    IF chuteParts:LENGTH = 0 {
        logMessage("printRealChuteInfo: no parts tagged '" + chuteTag + "' found.", "warning", TRUE, FALSE, TRUE).
        RETURN.
    }.

    FOR p IN chuteParts {
        PRINT "Part: " + p:NAME + " / tag: " + p:TAG.
        PRINT "  Modules: " + p:MODULES.

        IF p:HASMODULE("RealChuteModule") {
            LOCAL m IS p:GETMODULE("RealChuteModule").
            PRINT "  --- RealChuteModule ---".
            PRINT "  Fields:  " + m:ALLFIELDNAMES.
            PRINT "  Events:  " + m:ALLEVENTNAMES.
            PRINT "  Actions: " + m:ALLACTIONNAMES.
        } ELSE {
            PRINT "  (no RealChuteModule found)".
        }.
    }.
}.

// =====================================================
// ARMING
// =====================================================

// Arms all RealChute parachutes on parts tagged chuteTag.
// armEventName  -> the exact event name shown in the right-click menu.
//                  Defaults to "Arm Parachute" - verify with printRealChuteInfo().
// armActionName -> fallback if the event is not currently visible but an action exists.
DECLARE FUNCTION armRealChutes {
    DECLARE PARAMETER chuteTag IS "chute".
    DECLARE PARAMETER armEventName IS "Arm Parachute".
    DECLARE PARAMETER armActionName IS "Arm Parachute".

    LOCAL chuteParts IS SHIP:PARTSTAGGED(chuteTag).

    IF chuteParts:LENGTH = 0 {
        logMessage("armRealChutes: no parts tagged '" + chuteTag + "' found.", "warning", TRUE, FALSE, TRUE).
        RETURN FALSE.
    }.

    LOCAL armed IS 0.

    FOR p IN chuteParts {
        IF p:HASMODULE("RealChuteModule") {
            LOCAL m IS p:GETMODULE("RealChuteModule").

            // Prefer event (visible right-click button) over action.
            IF m:HASEVENT(armEventName) {
                m:DOEVENT(armEventName).
                SET armed TO armed + 1.
                logMessage("Parachute armed via event on part '" + p:TAG + "'.", "info", TRUE, FALSE, TRUE).
            } ELSE IF m:HASACTION(armActionName) {
                m:DOACTION(armActionName, TRUE).
                SET armed TO armed + 1.
                logMessage("Parachute armed via action on part '" + p:TAG + "'.", "info", TRUE, FALSE, TRUE).
            } ELSE {
                logMessage("Arm event/action not found on '" + p:TAG + "'. Run printRealChuteInfo() in sim to check exact names.", "warning", TRUE, FALSE, TRUE).
            }.
        } ELSE {
            logMessage("Part '" + p:TAG + "' has no RealChuteModule.", "warning", TRUE, FALSE, TRUE).
        }.
    }.

    logMessage("Parachutes armed: " + armed + "/" + chuteParts:LENGTH + ".", "alert", TRUE, FALSE, TRUE).
    RETURN armed = chuteParts:LENGTH.
}.

// =====================================================
// ALTITUDE-TRIGGERED ARMING
// =====================================================

// Arms a WHEN trigger that calls armRealChutes() when descending through armAlt.
// Use this in the post-launch section of a ship script.
DECLARE FUNCTION armChuteAtAltitude {
    DECLARE PARAMETER armAlt IS 5000.
    DECLARE PARAMETER chuteTag IS "chute".
    DECLARE PARAMETER armEventName IS "Arm Parachute".
    DECLARE PARAMETER armActionName IS "Arm Parachute".
    DECLARE PARAMETER useRadarAlt IS FALSE.

    logMessage("Chute arming trigger set for " + armAlt + "m on descent.", "info", TRUE, FALSE, TRUE).

    WHEN SHIP:VERTICALSPEED < 0 THEN {

        LOCAL currentAlt IS ALTITUDE.
        IF useRadarAlt { SET currentAlt TO ALT:RADAR. }.

        IF currentAlt < armAlt {
            logMessage("Arming altitude reached. Arming RealChute parachutes.", "alert", TRUE, TRUE, TRUE).
            armRealChutes(chuteTag, armEventName, armActionName).
        } ELSE {
            PRESERVE.
        }.
    }.
}.
