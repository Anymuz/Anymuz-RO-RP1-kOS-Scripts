// 0:/ships/bmidbar/Bmidbar-LR1.ks
// Main engine ignites while held on launch clamp.
// Clamp releases only after stable TWR confirmation.

RUNONCEPATH("0:/programs/bmidbar.ks").

// =====================================================
// MISSION CONFIG
// =====================================================
// Part tags must be set here and in-game.
// LOCAL boosterType IS "R103". // Set this to the part tag for the booster, used for fuel checks and staging, set to any non-existent tag if no booster stage.
// LOCAL mainEngine IS "U-1250". // Set this to the part tag for the main engine, used for fuel checks and staging.
// LOCAL fuelTank IS "SFT". // Set this to the part tag for the main   
// Countdown.
LOCAL countdownTime IS 10.

// Safety destruct.
LOCAL destructAlt IS 30000.
LOCAL useRadarAlt IS FALSE.

// Vehicle starting resources.
// These are for your own logs/checks and should match the vehicle design.
LOCAL boosterFuelLevel IS sumPartResource(boosterType, "Fuel"). // Set this to the initial fuel level of the boosters.
LOCAL propellantLevel IS sumPartResource(fuelTank, "Fuel"). // Set this to the absolute fuel level (not percentage) for main engine.
LOCAL oxidizerLevel IS sumPartResource(fuelTank, "Oxidizer"). // Set this to the absolute oxidizer level (not percentage) for main engine.
LOCAL pressurizerLevel IS sumPartResource(fuelTank, "Pressurizer"). // Set this to the absolute pressure level required for main engine.
LOCAL ignitiantLevel IS sumPartResource(mainEngine, "Ignitiant"). // Set this to the absolute level of the ignitiant for main engine, set to 0 if not used.
LOCAL electricChargeLevel IS sumPartResource(avionicsCore, "ElectricCharge"). // Set this to the absolute electric charge level of the ship.

// Engine monitoring.
LOCAL fuelThreshold IS 0.0588.
LOCAL mainEngineStartThreshold IS 0.13.

// Clamp-held launch.
LOCAL clampReleaseTWR IS 1.3.
LOCAL maxClampWait IS 15.
LOCAL requirePropellantDrain IS TRUE.

// Downrange guidance parameters.
LOCAL launchAzimuth IS 90.
LOCAL turnStartAlt IS 100.
LOCAL turnEndAlt IS 50000.
LOCAL finalPitch IS 43.
LOCAL turnShape IS 1.35.
LOCAL earlyControlAlt IS 1000.
LOCAL earlyMinPitch IS 78.
LOCAL guidanceEndAlt IS 90000.
LOCAL lockProgradeAfterGuidance IS TRUE.

// =====================================================
// SHIP CONFIG - DOES NOT SHARE DEFAULTS WITH R1 VARIENTS
// =====================================================

SET boosterType TO "R103".
SET mainEngine TO "U-1250".
SET fuelTank TO "HPSFT".

// Resource types.
SET boosterFuel TO "NGNC".
SET propellant TO "Kerosene".
SET oxidizer TO "AK20".
SET pressurizer TO "Nitrogen".
SET ignitiant TO "Tonka250.".

// =====================================================
// STARTUP
// =====================================================

initalizeBereshit(electricChargeLevel, shipVariant).

logMessage("Bereshit R2 downrange mission script loaded.", "mission", TRUE, FALSE, TRUE).
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
logMessage("Flight stats tracking online.", "online", TRUE, FALSE, TRUE).

monitorEngines(
    mainEngine,
    propellant,
    oxidizer,
    fuelThreshold,
    fuelTank,
    mainEngineStartThreshold
).
logMessage("Engine monitoring active.", "online", TRUE, FALSE, TRUE).

armDownrangeGuidance(
    launchAzimuth,
    turnStartAlt,
    turnEndAlt,
    finalPitch,
    turnShape,
    earlyControlAlt,
    earlyMinPitch,
    guidanceEndAlt,
    lockProgradeAfterGuidance
).
logMessage("Downrange guidance online.", "online", TRUE, FALSE, TRUE).

armAltitudeDetonation(destructAlt, useRadarAlt).
logMessage("Altitude safety detonator armed.", "warning", TRUE, FALSE, TRUE).

// =====================================================
// HOLD PROGRAM OPEN
// =====================================================

WAIT UNTIL FALSE.