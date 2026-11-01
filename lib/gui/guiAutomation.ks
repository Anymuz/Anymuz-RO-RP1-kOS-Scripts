// GUI AUTOMATION
// Registry of armable systems with a register-time AUTO/MANUAL flag. See docs/lib/gui/.
// --------------------------------------------------------------

// REGISTRY
// Each entry stores a name, action delegate, armed state, and manual flag.
GLOBAL guiSystems IS LIST().

// Register an arming delegate. MANUAL systems stay armed but do not fire automatically.
DECLARE FUNCTION registerSystem {
    DECLARE PARAMETER name.
    DECLARE PARAMETER action.
    DECLARE PARAMETER manual IS FALSE.

    guiSystems:ADD(LEXICON("name", name, "action", action, "armed", FALSE, "manual", manual)).
}.

// Find a registered system by name, or 0 if none.
DECLARE FUNCTION findSystem {
    DECLARE PARAMETER name.

    FOR sys IN guiSystems {
        IF sys["name"] = name {
            RETURN sys.
        }.
    }.
    RETURN 0.
}.

// Arm one system by name. Idempotent - does nothing if already armed.
DECLARE FUNCTION armSystem {
    DECLARE PARAMETER name.

    LOCAL sys IS findSystem(name).
    IF sys:ISTYPE("Lexicon") AND NOT sys["armed"] {
        sys["action"]:CALL().
        SET sys["armed"] TO TRUE.
        logMessage(name + " armed.", "action", TRUE, FALSE, TRUE).
    }.
}.

// Arm every registered system. MANUAL systems defer firing to their action logic.
DECLARE FUNCTION autoArmSystems {
    FOR sys IN guiSystems {
        IF NOT sys["armed"] {
            armSystem(sys["name"]).
        }.
    }.
}.

// TRUE if the named system is registered in MANUAL mode.
DECLARE FUNCTION systemManual {
    DECLARE PARAMETER name.

    LOCAL sys IS findSystem(name).
    IF sys:ISTYPE("Lexicon") {
        RETURN sys["manual"].
    }.
    RETURN FALSE.
}.
