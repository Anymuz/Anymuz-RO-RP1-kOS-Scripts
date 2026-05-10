// 0:/lib/downrange.ks

// Uses early kick-turn guidance instead of slow altitude-only pitch-over.
DECLARE FUNCTION clampValue {
    DECLARE PARAMETER value.
    DECLARE PARAMETER minValue.
    DECLARE PARAMETER maxValue.

    IF value < minValue {
        RETURN minValue.
    }.

    IF value > maxValue {
        RETURN maxValue.
    }.

    RETURN value.
}.

// Calculates target pitch based on altitude and defined turn profile.
DECLARE FUNCTION calculateDownrangePitch {
    DECLARE PARAMETER turnStartAlt IS 0.
    DECLARE PARAMETER kickEndAlt IS 300.
    DECLARE PARAMETER turnEndAlt IS 15000.
    DECLARE PARAMETER kickPitch IS 65.
    DECLARE PARAMETER finalPitch IS 30.
    DECLARE PARAMETER turnShape IS 0.6.

    IF turnEndAlt <= kickEndAlt {
        logMessage("Invalid downrange pitch settings: turnEndAlt must be greater than kickEndAlt.", "critical", TRUE, TRUE, TRUE).
        RETURN 90.
    }.

    IF kickEndAlt <= turnStartAlt {
        logMessage("Invalid downrange pitch settings: kickEndAlt must be greater than turnStartAlt.", "critical", TRUE, TRUE, TRUE).
        RETURN 90.
    }.

    IF ALTITUDE < turnStartAlt {
        RETURN 90.
    }.

    // Phase 1:
    // Immediate visible kick from vertical to kickPitch.
    IF ALTITUDE < kickEndAlt {

        LOCAL kickProgress IS (ALTITUDE - turnStartAlt) / (kickEndAlt - turnStartAlt).
        SET kickProgress TO clampValue(kickProgress, 0, 1).

        RETURN 90 - ((90 - kickPitch) * kickProgress).
    }.

    // Phase 2:
    // Continue from kickPitch down to finalPitch.
    LOCAL rawProgress IS (ALTITUDE - kickEndAlt) / (turnEndAlt - kickEndAlt).
    LOCAL progress IS clampValue(rawProgress, 0, 1).

    // turnShape below 1 = more aggressive early turn.
    // turnShape above 1 = holds steeper for longer.
    LOCAL curvedProgress IS progress ^ turnShape.

    LOCAL targetPitch IS kickPitch - ((kickPitch - finalPitch) * curvedProgress).

    RETURN clampValue(targetPitch, finalPitch, 90).
}.

// Logs the defined downrange guidance profile parameters.
DECLARE FUNCTION logDownrangeProfile {
    DECLARE PARAMETER launchAzimuth IS 90.
    DECLARE PARAMETER turnStartAlt IS 0.
    DECLARE PARAMETER kickEndAlt IS 300.
    DECLARE PARAMETER turnEndAlt IS 15000.
    DECLARE PARAMETER kickPitch IS 65.
    DECLARE PARAMETER finalPitch IS 30.
    DECLARE PARAMETER turnShape IS 0.6.
    DECLARE PARAMETER guidanceEndAlt IS 90000.
    DECLARE PARAMETER lockProgradeAfterGuidance IS TRUE.

    CLEARSCREEN.
    logMessage("Downrange guidance profile loaded.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Launch azimuth: " + launchAzimuth + " degrees.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Turn start altitude: " + turnStartAlt + "m.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Kick end altitude: " + kickEndAlt + "m.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Turn end altitude: " + turnEndAlt + "m.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Kick pitch: " + kickPitch + " degrees.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Final powered pitch: " + finalPitch + " degrees.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Turn shape: " + turnShape + ".", "guidance", TRUE, FALSE, TRUE).
    logMessage("Guidance end altitude: " + guidanceEndAlt + "m.", "guidance", TRUE, FALSE, TRUE).
    logMessage("Prograde hold after guidance: " + lockProgradeAfterGuidance + ".", "guidance", TRUE, FALSE, TRUE).
}.

//` Arms the downrange guidance profile, applying calculated pitch targets and logging progress.
DECLARE FUNCTION armDownrangeGuidance {
    DECLARE PARAMETER launchAzimuth IS 90.
    DECLARE PARAMETER turnStartAlt IS 0.
    DECLARE PARAMETER kickEndAlt IS 300.
    DECLARE PARAMETER turnEndAlt IS 15000.
    DECLARE PARAMETER kickPitch IS 65.
    DECLARE PARAMETER finalPitch IS 30.
    DECLARE PARAMETER turnShape IS 0.6.
    DECLARE PARAMETER guidanceEndAlt IS 90000.
    DECLARE PARAMETER lockProgradeAfterGuidance IS TRUE.

    LOCAL guidanceComplete IS FALSE.
    LOCAL apogeeReleaseLogged IS FALSE.
    LOCAL lastLogTime IS 0.

    logDownrangeProfile(
        launchAzimuth,
        turnStartAlt,
        kickEndAlt,
        turnEndAlt,
        kickPitch,
        finalPitch,
        turnShape,
        guidanceEndAlt,
        lockProgradeAfterGuidance
    ).

    logMessage("Downrange steering armed.", "online", TRUE, FALSE, TRUE).
    CLEARSCREEN.
    WHEN TRUE THEN {

        IF NOT guidanceComplete {

            LOCAL targetPitch IS calculateDownrangePitch(
                turnStartAlt,
                kickEndAlt,
                turnEndAlt,
                kickPitch,
                finalPitch,
                turnShape
            ).
            WAIT 0.1.
            CLEARSCREEN.
            PRINT "                                                                                                                                      " AT (0,10).
            PRINT "======================================================" AT(0,11).
            PRINT "TARGET PITCH: " + ROUND(targetPitch, 2) + " | ALT: " + ROUND(ALTITUDE, 1) + "     " AT(0,12).
            PRINT "======================================================" AT(0,13).
            PRINT "                                                                                                                                      " AT (0,14).

            LOCK STEERING TO HEADING(launchAzimuth, targetPitch).

            IF TIME:SECONDS > lastLogTime + 5 {
                logMessage(
                    "Guidance target pitch: " + ROUND(targetPitch, 2) +
                    " deg | Altitude: " + ROUND(ALTITUDE, 1) +
                    "m | Velocity: " + ROUND(SHIP:VELOCITY:SURFACE:MAG, 1) + "m/s.",
                    "guidance",
                    TRUE,
                    FALSE,
                    FALSE
                ).

                SET lastLogTime TO TIME:SECONDS.
            }.

            IF ALTITUDE >= guidanceEndAlt {
                CLEARSCREEN.
                SET guidanceComplete TO TRUE.
                logMessage("Downrange pitch program complete.", "guidance", TRUE, FALSE, TRUE).

                IF lockProgradeAfterGuidance {
                    logMessage("Switching to surface prograde hold.", "guidance", TRUE, FALSE, TRUE).
                    LOCK STEERING TO SHIP:SRFPROGRADE.
                } ELSE {
                    logMessage("Steering unlocked after downrange guidance.", "guidance", TRUE, FALSE, TRUE).
                    UNLOCK STEERING.
                }.
            }.

            PRESERVE.

        } ELSE {

            IF lockProgradeAfterGuidance AND SHIP:VERTICALSPEED > 0 {
                LOCK STEERING TO SHIP:SRFPROGRADE.
                PRESERVE.
            }.

            IF lockProgradeAfterGuidance AND SHIP:VERTICALSPEED <= 0 AND NOT apogeeReleaseLogged {
                CLEARSCREEN.
                logMessage("Apogee reached. Downrange steering released.", "guidance", TRUE, FALSE, TRUE).
                UNLOCK STEERING.
                SET apogeeReleaseLogged TO TRUE.
            }.
        }.
    }.
}.