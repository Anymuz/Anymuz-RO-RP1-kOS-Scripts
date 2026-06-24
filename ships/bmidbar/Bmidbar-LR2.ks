RUNONCEPATH("0:/programs/bmidbar.ks").
LOCAL countdownTime IS 10.
LOCAL deployAlt IS 7000.
LOCAL parachuteType IS "LR-PARACHUTE".  // Set this to the part tag for the parachute, used for parachute deployment checks, set to any non-existent tag if not using parachutes.
LOCAL fairingType IS "CHUTE-CASE".  // Set this to the part tag for the fairing, used for fairing jettison checks, set to any non-existent tag if not using fairings.
LOCAL useRadarAlt IS FALSE.

// Clamp-held launch.
LOCAL clampReleaseTWR IS 1.3.
LOCAL maxClampWait IS 5.
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
// LOCAL turnStartAlt IS 0.
// LOCAL kickEndAlt IS 1000.
// LOCAL turnEndAlt IS 35000.
// LOCAL kickPitch IS 70.
// LOCAL finalPitch IS 40.
// LOCAL turnShape IS 0.85.
// LOCAL guidanceEndAlt IS 70000.
// LOCAL lockProgradeAfterGuidance IS FALSE.

//  LOCAL launchAzimuth IS 90.
//  Previous working profile:
LOCAL turnStartAlt IS 0.
LOCAL kickEndAlt IS 1000.
LOCAL turnEndAlt IS 35000.
LOCAL kickPitch IS 80.
LOCAL finalPitch IS 40.
LOCAL turnShape IS 1.
//LOCAL turnShape IS 0.85.
LOCAL guidanceEndAlt IS 90000.
//LOCAL guidanceEndAlt IS 70000.
LOCAL lockProgradeAfterGuidance IS FALSE.

// Downrange sounding profile:
// LOCAL turnStartAlt IS 0.
// LOCAL kickEndAlt IS 1000.
// LOCAL turnEndAlt IS 50000.
// LOCAL kickPitch IS 75.
// LOCAL finalPitch IS 30.
// LOCAL turnShape IS 0.8.
// LOCAL guidanceEndAlt IS 100000.
// LOCAL lockProgradeAfterGuidance IS TRUE.

// USE THIS IF ALL ELSE FAILS::
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
RUNONCEPATH("0:/lib/parachute.ks").
initalizeBmidbar(electricChargeLevel, shipVariant).

logMessage("Bmidbar LR2 planetary reconnaissance loaded.", "mission", TRUE, FALSE, TRUE).
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


armParachute(
    parachuteType, 
    deployAlt, 
    useRadarAlt, 
    fairingType
).
logMessage("Parachutes armed.", "warning", TRUE, FALSE, TRUE).

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

//CLEARSCREEN.
// =====================================================
// HOLD PROGRAM OPEN
// =====================================================

WAIT UNTIL FALSE.