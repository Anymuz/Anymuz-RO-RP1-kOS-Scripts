// PARTS
// Trigger actions/events on tagged parts, after checking they are available.
// Use boot/partDump.ks to find action and event names.
// --------------------------------------------------------------

// TRUE if any part carries this tag.
DECLARE FUNCTION taggedPartsExist {
    DECLARE PARAMETER partTag.

    RETURN SHIP:PARTSTAGGED(partTag):LENGTH > 0.
}.

// TRUE if the part has a module exposing actionName.
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

// TRUE if the part has a module exposing eventName.
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

// Fire actionName on one part (first module that has it). Returns TRUE if fired.
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

// Fire eventName on one part (first module that has it). Returns TRUE if fired.
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

// Fire actionName on every part tagged partTag. Returns the count acted on.
// Warns (does nothing else) if the tag matched nothing or the parts lack the action.
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

// Fire eventName on every part tagged partTag. Returns the count acted on.
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

// Resolve action modules before firing so scanning cannot delay multi-part ignition.
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

// Fire resolved actions in one tick by raising kOS's instruction budget.
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
