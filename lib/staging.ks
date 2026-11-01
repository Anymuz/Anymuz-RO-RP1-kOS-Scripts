// EXPLAINATION
// Apogee trigger that fires an action on a tagged part
// --------------------------------------------------------------

// APOGEE EVENT
// Arms a one-shot action on a tagged part at apogee
DECLARE FUNCTION armApogeeStaging {
    DECLARE PARAMETER triggerVelocity IS -1.   // m/s
    DECLARE PARAMETER minAltitude IS 1000.   // metres
    DECLARE PARAMETER useRadarAlt IS FALSE.
    DECLARE PARAMETER postApogeeDelay IS 3.   // seconds
    DECLARE PARAMETER markCoast IS FALSE.   // TRUE = set phase to coast
    DECLARE PARAMETER separatorTag IS "".
    DECLARE PARAMETER actionName IS "decouple".

    LOCAL fired IS FALSE.

    // Resolved up front so the trigger only has to fire
    LOCAL separatorModules IS resolveTaggedActionModules(separatorTag, actionName).
    IF separatorModules:LENGTH = 0 {
        logMessage("Apogee event: no part tagged '" + separatorTag + "' has action '" + actionName + "'.", "warning", TRUE, FALSE, TRUE).
    }.

    logMessage("Apogee event armed (trigger " + triggerVelocity + " m/s, min alt " + minAltitude + "m).", "online", TRUE, FALSE, TRUE).

    WHEN NOT fired AND SHIP:VERTICALSPEED < triggerVelocity AND (CHOOSE ALT:RADAR IF useRadarAlt ELSE ALTITUDE) > minAltitude THEN {
        SET fired TO TRUE.
        logMessage("Apogee reached. Firing in " + postApogeeDelay + "s.", "alert", TRUE, TRUE, TRUE).

        LOCAL fireTime IS TIME:SECONDS + postApogeeDelay.
        WHEN TIME:SECONDS >= fireTime THEN {
            IF markCoast AND flightData["phase"] <> "descent" {
                SET flightData["phase"] TO "coast".
            }.
            igniteResolvedModules(separatorModules, actionName).
            logMessage("Apogee event fired.", "alert", TRUE, TRUE, TRUE).
        }.
    }.
}.
// --------------------------------------------------------------