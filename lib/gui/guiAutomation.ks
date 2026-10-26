// GUI AUTOMATION
// Registry of armable systems with a register-time AUTO/MANUAL flag. See docs/lib/gui/.
// --------------------------------------------------------------

// REGISTRY
// Each entry: LEXICON("name", <string>, "action", <delegate>, "armed", <bool>, "manual", <bool>).
GLOBAL guiSystems IS LIST().

// Register an armable system. `action` is a no-argument delegate that performs the
// arming (it should capture the ship's parameters). `manual` starts it in manual
// mode (automatic action held) if TRUE - this is the only way to set manual mode;
// there is no live pilot toggle for it.
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

// Arm every registered system (set up its automatic logic). Systems registered as
// MANUAL are still armed, but their automatic action checks systemManual() and
// holds instead of firing. The ship script calls this at post-launch where it
// used to arm systems directly.
DECLARE FUNCTION autoArmSystems {
    FOR sys IN guiSystems {
        IF NOT sys["armed"] {
            armSystem(sys["name"]).
        }.
    }.
}.

// TRUE if the named system is registered and the pilot has it in MANUAL. Autonomous
// code (e.g. the auto-destruct in lib/detonation.ks) checks this before firing.
// Unknown systems return FALSE, so anything not registered stays fully automatic.
DECLARE FUNCTION systemManual {
    DECLARE PARAMETER name.

    LOCAL sys IS findSystem(name).
    IF sys:ISTYPE("Lexicon") {
        RETURN sys["manual"].
    }.
    RETURN FALSE.
}.

