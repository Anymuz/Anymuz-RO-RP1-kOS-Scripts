RUNONCEPATH("0:/programs/bmidbar.ks").
// --------------------------------------------------------------

// CONFIGURATION
LOCAL countdownTime IS 10.
LOCAL deployAlt IS 7000.
LOCAL parachuteType IS "LR-PARACHUTE".  // Set this to the part tag for the parachute, used for parachute deployment checks, set to any non-existent tag if not using parachutes.
LOCAL fairingType IS "CHUTE-CASE".  // Set this to the part tag for the fairing, used for fairing jettison checks, set to any non-existent tag if not using fairings.
LOCAL useRadarAlt IS FALSE.

// Clamp-held launch.
LOCAL clampReleaseTWR IS 1.3.
LOCAL maxClampWait IS 5.
LOCAL requirePropellantDrain IS FALSE.

// Apogee staging parameters.
LOCAL apogeeStageVelocity IS -1. // Vertical speed (m/s) at or below which apogee is declared.
LOCAL apogeeStageMinAlt IS 20000. // Only stage above this altitude; guards against early-flight transients.
LOCAL apogeeStageDelay IS 3. // Seconds to coast past apogee before staging.

// LR3 guidance profile:
LOCAL launchAzimuth IS 90.
LOCAL turnStartAlt IS 0.
LOCAL kickEndAlt IS 1000.
LOCAL turnEndAlt IS 35000.
LOCAL kickPitch IS 80.
LOCAL finalPitch IS 30.
LOCAL turnShape IS 0.95.
LOCAL guidanceEndAlt IS 90000.
LOCAL lockProgradeAfterGuidance IS FALSE.
// --------------------------------------------------------------

// STARTUP
initalizeBmidbar(electricChargeLevel, shipVariant).
logMessage("Bmidbar LR3 planetary reconnaissance loaded.", "mission", TRUE, FALSE, TRUE).
logMessage("Clamp release TWR target: " + clampReleaseTWR + ".", "mission", TRUE, FALSE, TRUE).
skipLine().
// --------------------------------------------------------------

// LAUNCH SEQUENCE
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
// --------------------------------------------------------------

// POST-LAUNCH SYSTEMS
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

armApogeeStaging(
    apogeeStageVelocity,
    apogeeStageMinAlt,
    useRadarAlt,
    apogeeStageDelay,
    FALSE
).
logMessage("Apogee staging armed.", "alert", TRUE, FALSE, TRUE).
//CLEARSCREEN.
// --------------------------------------------------------------

// HOLD PROGRAM
WAIT UNTIL FALSE.
// --------------------------------------------------------------