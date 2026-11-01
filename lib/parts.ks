// EXPLAINATION
// Fires tagged part actions and events directly, names from boot/partDump.ks
// --------------------------------------------------------------

// PART CHECKS
// TRUE if tag exists
DECLARE FUNCTION taggedPartsExist {
    DECLARE PARAMETER partTag.

    RETURN SHIP:PARTSTAGGED(partTag):LENGTH > 0.
}.

// TRUE if part has the action
DECLARE FUNCTION partHasAction {
    DECLARE PARAMETER part.
    DECLARE PARAMETER actionName.

    FOR moduleName IN part:MODULES {
        IF part:GETMODULE(moduleName):HASACTION(actionName) {
            RETURN TRUE.
        }.
    }.
    RETURN FALSE.
}.

// TRUE if part has the event
DECLARE FUNCTION partHasEvent {
    DECLARE PARAMETER part.
    DECLARE PARAMETER eventName.

    FOR moduleName IN part:MODULES {
        IF part:GETMODULE(moduleName):HASEVENT(eventName) {
            RETURN TRUE.
        }.
    }.
    RETURN FALSE.
}.
// --------------------------------------------------------------

// SINGLE PART ACTIONS
// Fires an action on one part
DECLARE FUNCTION doPartAction {
    DECLARE PARAMETER part.
    DECLARE PARAMETER actionName.
    DECLARE PARAMETER activate IS TRUE.

    FOR moduleName IN part:MODULES {
        LOCAL partModule IS part:GETMODULE(moduleName).
        IF partModule:HASACTION(actionName) {
            partModule:DOACTION(actionName, activate).
            RETURN TRUE.
        }.
    }.
    RETURN FALSE.
}.

// Fires an event on one part
DECLARE FUNCTION doPartEvent {
    DECLARE PARAMETER part.
    DECLARE PARAMETER eventName.

    FOR moduleName IN part:MODULES {
        LOCAL partModule IS part:GETMODULE(moduleName).
        IF partModule:HASEVENT(eventName) {
            partModule:DOEVENT(eventName).
            RETURN TRUE.
        }.
    }.
    RETURN FALSE.
}.
// --------------------------------------------------------------

// TAGGED PART ACTIONS
// Fires an action on every tagged part
DECLARE FUNCTION doTaggedAction {
    DECLARE PARAMETER partTag.
    DECLARE PARAMETER actionName.
    DECLARE PARAMETER activate IS TRUE.

    LOCAL tagged IS SHIP:PARTSTAGGED(partTag).
    IF tagged:LENGTH = 0 {
        logMessage("No parts tagged '" + partTag + "' for action '" + actionName + "'.", "warning", TRUE, FALSE, TRUE).
        RETURN 0.
    }.

    LOCAL done IS 0.
    FOR part IN tagged {
        IF doPartAction(part, actionName, activate) {
            SET done TO done + 1.
        }.
    }.

    IF done = 0 {
        logMessage("Parts tagged '" + partTag + "' expose no action '" + actionName + "'.", "warning", TRUE, FALSE, TRUE).
    }.
    RETURN done.
}.

// Fires an event on every tagged part
DECLARE FUNCTION doTaggedEvent {
    DECLARE PARAMETER partTag.
    DECLARE PARAMETER eventName.

    LOCAL tagged IS SHIP:PARTSTAGGED(partTag).
    IF tagged:LENGTH = 0 {
        logMessage("No parts tagged '" + partTag + "' for event '" + eventName + "'.", "warning", TRUE, FALSE, TRUE).
        RETURN 0.
    }.

    LOCAL done IS 0.
    FOR part IN tagged {
        IF doPartEvent(part, eventName) {
            SET done TO done + 1.
        }.
    }.

    IF done = 0 {
        logMessage("Parts tagged '" + partTag + "' expose no event '" + eventName + "'.", "warning", TRUE, FALSE, TRUE).
    }.
    RETURN done.
}.
// --------------------------------------------------------------

// SIMULTANEOUS IGNITION
// Finds action modules ahead of time
DECLARE FUNCTION resolveTaggedActionModules {
    DECLARE PARAMETER partTag.
    DECLARE PARAMETER actionName.

    LOCAL found IS LIST().
    FOR part IN SHIP:PARTSTAGGED(partTag) {
        FOR moduleName IN part:MODULES {
            LOCAL partModule IS part:GETMODULE(moduleName).
            IF partModule:HASACTION(actionName) {
                found:ADD(partModule).
                BREAK.
            }.
        }.
    }.
    RETURN found.
}.

// Fires found modules together, same tick
DECLARE FUNCTION igniteResolvedModules {
    DECLARE PARAMETER modules.
    DECLARE PARAMETER actionName.
    DECLARE PARAMETER activate IS TRUE.

    LOCAL previousIPU IS CONFIG:IPU.
    SET CONFIG:IPU TO MAX(previousIPU, 2000).

    FOR partModule IN modules {
        partModule:DOACTION(actionName, activate).
    }.

    SET CONFIG:IPU TO previousIPU.
    RETURN modules:LENGTH.
}.
// --------------------------------------------------------------

