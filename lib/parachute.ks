// 0:/lib/parachute.ks
// RealChute parachute arming helpers.
// Designed for RealChute parachutes in RO/RP1. Requires lib/logging.ks.
//
// HOW REALCHUTE WORKS:
//   Arming is all you need to do from kOS. When you arm the chute, RealChute
//   stages it internally and then deploys it automatically once conditions are
//   safe (correct altitude and dynamic pressure). No separate deploy call needed.
//
// TYPICAL USAGE in a ship script:
//   RUNONCEPATH("0:/lib/parachute.ks").
//   armChuteAtAltitude(8000, "chute").  // arm when descending through 8 km
//
// FIRST TIME SETUP:
//   Run printRealChuteInfo("chute") in simulation to see the exact event/action
//   names your RealChute version exposes, then pass them to the functions below.
//
// All functions are pure helpers - no side effects at load time.

// =====================================================
// DEBUG / DISCOVERY
// =====================================================

// Prints every module, event, action, and field on parts tagged chuteTag.
// Run this ONCE in simulation to discover the exact names RealChute exposes
// on your build/version. The defaults in the other functions below match the
// most common names, but they can differ between RealChute versions.
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
            // These three lists are what you need - copy the names exactly
            // into armEventName / deployEventName parameters below.
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
// In RealChute, "arming" puts the chute into a ready state so it can deploy
// when it detects safe dynamic pressure. You must arm before deploying.
// Typically done at high altitude (e.g. 8-10 km) before dynamic pressure builds.

// Arms all RealChute parachutes on parts tagged chuteTag.
//   chuteTag     -> VAB tag on your chute parts (default "chute").
//   armEventName -> right-click menu event name (verify with printRealChuteInfo).
//   armActionName-> fallback action group name if the event is not visible.
// Returns TRUE if all chutes were successfully armed.
DECLARE FUNCTION armRealChutes {
    DECLARE PARAMETER chuteTag IS "chute".
    // armEventName / armActionName: get these by running printRealChuteInfo("chute")
    // in simulation. Copy the string exactly from the "Events" or "Actions" line.
    // Defaults confirmed from RealChuteModule.cs source (github.com/ChrisViral/RealChute).
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

            // Events are the right-click buttons; they are only available when
            // the game logic allows that action right now (e.g. not already armed).
            // Actions are always available regardless of state.
            // Try the event first; fall back to the action if the event is hidden.
            IF m:HASEVENT(armEventName) {
                m:DOEVENT(armEventName).
                SET armed TO armed + 1.
                logMessage("Parachute armed (event) on '" + p:TAG + "'.", "info", TRUE, FALSE, TRUE).
            } ELSE IF m:HASACTION(armActionName) {
                m:DOACTION(armActionName, TRUE).
                SET armed TO armed + 1.
                logMessage("Parachute armed (action) on '" + p:TAG + "'.", "info", TRUE, FALSE, TRUE).
            } ELSE {
                // Neither found - most likely the event/action name is wrong for
                // this RealChute version. Run printRealChuteInfo() to check.
                logMessage("Arm event/action not found on '" + p:TAG + "'. Run printRealChuteInfo() to check names.", "warning", TRUE, FALSE, TRUE).
            }.
        } ELSE {
            logMessage("Part '" + p:TAG + "' has no RealChuteModule.", "warning", TRUE, FALSE, TRUE).
        }.
    }.

    logMessage("Parachutes armed: " + armed + "/" + chuteParts:LENGTH + ".", "alert", TRUE, FALSE, TRUE).
    RETURN armed = chuteParts:LENGTH.
}.

// Sets a descent trigger that calls armRealChutes() when falling through armAlt.
// Call this early in flight (e.g. after apogee) so the trigger is watching.
//   armAlt       -> altitude in metres at which to arm (ASL unless useRadarAlt).
//   chuteTag     -> VAB tag on your chute parts.
//   armEventName -> event name from printRealChuteInfo().
//   armActionName-> fallback action name from printRealChuteInfo().
//   useRadarAlt  -> TRUE = use radar (ground) altitude, FALSE = use sea-level altitude.
DECLARE FUNCTION armChuteAtAltitude {
    DECLARE PARAMETER armAlt IS 8000.
    DECLARE PARAMETER chuteTag IS "chute".
    // Defaults confirmed from RealChuteModule.cs source (github.com/ChrisViral/RealChute).
    DECLARE PARAMETER armEventName IS "Arm parachute".
    DECLARE PARAMETER armActionName IS "Arm parachute".
    DECLARE PARAMETER useRadarAlt IS FALSE.

    logMessage("Chute arm trigger set: descend through " + armAlt + "m.", "info", TRUE, FALSE, TRUE).

    // WHEN fires repeatedly until it does not PRESERVE. Once the altitude
    // condition is met the chutes are armed and the trigger naturally expires.
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
