// EXPLAINATION
// Registry of armable systems with an auto/manual flag
// --------------------------------------------------------------

// REGISTRY
GLOBAL guiSystems IS LIST().

// Registers a system, manual holds the auto action
DECLARE FUNCTION registerSystem {
    DECLARE PARAMETER name.
    DECLARE PARAMETER action.
    DECLARE PARAMETER manual IS FALSE.

    guiSystems:ADD(LEXICON("name", name, "action", action, "armed", FALSE, "manual", manual)).
}.

// Finds a system by name, 0 if none
DECLARE FUNCTION findSystem {
    DECLARE PARAMETER name.

    FOR sys IN guiSystems {
        IF sys["name"] = name {
            RETURN sys.
        }.
    }.
    RETURN 0.
}.

// Arms one system, once only
DECLARE FUNCTION armSystem {
    DECLARE PARAMETER name.

    LOCAL sys IS findSystem(name).
    IF sys:ISTYPE("Lexicon") AND NOT sys["armed"] {
        sys["action"]:CALL().
        SET sys["armed"] TO TRUE.
        logMessage(name + " armed.", "action", TRUE, FALSE, TRUE).
    }.
}.

// Arms every registered system
DECLARE FUNCTION autoArmSystems {
    FOR sys IN guiSystems {
        IF NOT sys["armed"] {
            armSystem(sys["name"]).
        }.
    }.
}.

// TRUE if system is in manual mode
DECLARE FUNCTION systemManual {
    DECLARE PARAMETER name.

    LOCAL sys IS findSystem(name).
    IF sys:ISTYPE("Lexicon") {
        RETURN sys["manual"].
    }.
    RETURN FALSE.
}.
// --------------------------------------------------------------

