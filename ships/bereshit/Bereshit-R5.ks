// INITALIZATION
//RUNONCEPATH("0:/programs/bereshit.ks"). // Import ship specific functions and telemetry.
RUNONCEPATH("0:/programs/"+ shipSeries:TOLOWER() +".ks").
// --------------------------------------------------------------

// CONFIGUTION
LOCAL countdownTime IS 10. // Seconds to count down from before launch.
LOCAL deployAlt IS 15000. //  Science data wont be collected below this altitude -> safe destruct altitude to prevent ground impact.
LOCAL useRadarAlt IS FALSE. // Set to true to use radar altitude for destruct, false for sea level altitude. Radar accurate but less stable.
LOCAL parachuteType IS "V1-PARACHUTE". // Set this to the part tag for the parachute, used for parachute deployment checks, set to any non-existent tag if not using parachutes.
LOCAL fairingType IS "CHUTE-CASE". // Set this to the part tag for the fairing, used for fairing jettison checks, set to any non-existent tag if not using fairings.

// Apogee staging parameters.
LOCAL apogeeStageVelocity IS -1. // Vertical speed (m/s) at or below which apogee is declared.
LOCAL apogeeStageMinAlt IS 20000. // Only stage above this altitude; guards against early-flight transients.
LOCAL apogeeStageDelay IS 3. // Seconds to coast past apogee before staging.
// --------------------------------------------------------------

// STARTUP
initalizeProgram(). // Checks for electric charge and logs startup messages.
// --------------------------------------------------------------

// LAUNCH SEQUENCE
initializeLaunch(). // Waits for user input to start the launch sequence.
countdownLaunch(countdownTime). // Counts down from specified time
launchShip(). // launches the ship and plays sound.
// --------------------------------------------------------------

// POST LAUNCH SYSTEMS
armBoosterSeperation(boosterType, boosterFuel, (boosterPreigniteMainThreshold*boosterFuelLevel), (boosterShutdownThreshold * boosterFuelLevel)).
logMessage("Booster separation charges armed.", "alert", TRUE, FALSE, TRUE).
trackFlightStats().
logMessage("Flight stats tracking online.", "online", TRUE, FALSE, TRUE).
monitorEngines(mainEngine, propellant, oxidizer, fuelThreshold, fuelTank, mainEngineStartThreshold).
logMessage("Engine monitoring active.", "online", TRUE, FALSE, TRUE).
armApogeeStaging(apogeeStageVelocity, apogeeStageMinAlt, useRadarAlt, apogeeStageDelay, FALSE).
logMessage("Apogee staging armed.", "alert", TRUE, FALSE, TRUE).
armParachute(parachuteType, deployAlt, useRadarAlt, fairingType).
logMessage("Parachutes armed.", "warning", TRUE, FALSE, TRUE).
// --------------------------------------------------------------

// HOLD PROGRAM
WAIT UNTIL FALSE.
// --------------------------------------------------------------