// 0:/lib/staging.ks
// Event-driven staging triggers. Fires STAGE events off flight conditions.
// Requires lib/logging.ks (logMessage) and a flightData LEXICON.
// Designed to run alongside trackFlightStats, armBoosterSeperation,
// armParachute and armAltitudeDetonation without fighting them for
// control of flightData["phase"].

// Arms a one-shot stage event at apogee.
// Apogee is declared on the first sustained negative vertical speed above
// minAltitude, mirroring the descent detection used in tracking.ks/parachute.ks.
//   triggerVelocity -> vertical speed (m/s) at or below which apogee is declared.
//   minAltitude     -> only stage above this altitude; guards early-flight transients.
//   useRadarAlt     -> TRUE = radar altitude for minAltitude, FALSE = sea-level altitude.
//   postApogeeDelay -> seconds to coast past apogee before staging (settling time).
//   markCoast       -> TRUE = set flightData["phase"] to "coast" at stage
//                      (skipped if a downstream trigger already set "descent").
DECLARE FUNCTION armApogeeStaging {
    DECLARE PARAMETER triggerVelocity IS -1.
    DECLARE PARAMETER minAltitude IS 1000.
    DECLARE PARAMETER useRadarAlt IS FALSE.
    DECLARE PARAMETER postApogeeDelay IS 3.
    DECLARE PARAMETER markCoast IS FALSE.

    LOCAL staged IS FALSE.

    logMessage("Apogee staging armed (trigger " + triggerVelocity + " m/s, min alt " + minAltitude + "m).", "online", TRUE, FALSE, TRUE).

    // Wait for the apogee crossing above the safety altitude.
    WHEN NOT staged AND SHIP:VERTICALSPEED < triggerVelocity AND (CHOOSE ALT:RADAR IF useRadarAlt ELSE ALTITUDE) > minAltitude THEN {
        SET staged TO TRUE.
        logMessage("Apogee reached. Staging in " + postApogeeDelay + "s.", "alert", TRUE, TRUE, TRUE).

        // Coast briefly past apogee so the stack is settled before separation.
        LOCAL stageTime IS TIME:SECONDS + postApogeeDelay.
        WHEN TIME:SECONDS >= stageTime THEN {
            IF markCoast AND flightData["phase"] <> "descent" {
                SET flightData["phase"] TO "coast".
            }.
            STAGE.
            logMessage("Apogee stage event fired.", "alert", TRUE, TRUE, TRUE).
        }.
    }.
}.
