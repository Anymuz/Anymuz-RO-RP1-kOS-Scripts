RUNONCEPATH("0:/programs/bmidbar.ks").
LOCAL countdownTime IS 10.
LOCAL destructAlt IS 30000.
LOCAL useRadarAlt IS FALSE.

// Clamp-held launch.
LOCAL clampReleaseTWR IS 1.3.
LOCAL maxClampWait IS 15.
LOCAL requirePropellantDrain IS FALSE.

// Downrange guidance parameters.
// LOCAL launchAzimuth IS 90.
// LOCAL turnStartAlt IS 100.
// LOCAL finalPitch IS 40.
// LOCAL turnShape IS 1.25.
// LOCAL turnEndAlt IS 45000.
// LOCAL earlyControlAlt IS 1000.
// LOCAL earlyMinPitch IS 78.
// LOCAL guidanceEndAlt IS 90000.
// LOCAL lockProgradeAfterGuidance IS TRUE.

 LOCAL launchAzimuth IS 90.

// LOCAL turnStartAlt IS 50.
// LOCAL turnEndAlt IS 35000.
// LOCAL finalPitch IS 38.
// LOCAL turnShape IS 1.05.

// LOCAL earlyControlAlt IS 500.
// LOCAL earlyMinPitch IS 72.

LOCAL turnStartAlt IS 0.
LOCAL kickEndAlt IS 1000.
LOCAL turnEndAlt IS 30000.
LOCAL kickPitch IS 80.
LOCAL finalPitch IS 40.
LOCAL turnShape IS 1.0.
LOCAL guidanceEndAlt IS 90000.
LOCAL lockProgradeAfterGuidance IS TRUE.

// USE THIS:
// LOCAL turnStartAlt IS 0.
// LOCAL kickEndAlt IS 1200.
// LOCAL turnEndAlt IS 35000.
// LOCAL kickPitch IS 82.
// LOCAL finalPitch IS 42.
// LOCAL turnShape IS 1.1.
// LOCAL guidanceEndAlt IS 90000.
// LOCAL lockProgradeAfterGuidance IS TRUE.

// ================================
// STARTUP
// =====================================================

initalizeBmidbar(electricChargeLevel, shipVariant).

logMessage("Bmidbar LR1 downrange mission script loaded.", "mission", TRUE, FALSE, TRUE).
logMessage("No booster stage configured for this vehicle.", "mission", TRUE, FALSE, TRUE).
logMessage("Clamp release TWR target: " + clampReleaseTWR + ".", "mission", TRUE, FALSE, TRUE).
skipLine().

// =====================================================
// LAUNCH SEQUENCE
// =====================================================

initializeLaunch().
countdownLaunch(countdownTime).

IF NOT launchShipClampTWR(
    mainEngine,
    fuelTank,
    propellant,
    oxidizer,
    clampReleaseTWR,
    maxClampWait,
    launchAzimuth,
    requirePropellantDrain
) {
    logMessage("Mission ended during clamp-held launch attempt.", "abort", TRUE, TRUE, TRUE).
    outputFlightData().
    WAIT UNTIL FALSE.
}.

// =====================================================
// POST-LAUNCH SYSTEMS
// =====================================================

trackFlightStats().
logMessage("Flight stats tracking online.", "online", TRUE, FALSE, FALSE).

monitorEngines(
    mainEngine,
    propellant,
    oxidizer,
    fuelThreshold,
    fuelTank,
    mainEngineStartThreshold
).
logMessage("Engine monitoring active.", "online", TRUE, FALSE, FALSE).

armDownrangeGuidance(
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
logMessage("Downrange guidance online.", "online", TRUE, FALSE, FALSE).

armAltitudeDetonation(destructAlt, useRadarAlt).
logMessage("Altitude safety detonator armed.", "warning", TRUE, FALSE, FALSE).
//CLEARSCREEN.
// =====================================================
// HOLD PROGRAM OPEN
// =====================================================

WAIT UNTIL FALSE.