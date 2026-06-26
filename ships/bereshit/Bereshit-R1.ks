// INITALIZATION
//RUNONCEPATH("0:/programs/bereshit.ks"). // Import ship specific functions and telemetry.
RUNONCEPATH("0:/programs/"+ shipSeries:TOLOWER() +".ks").
// --------------------------------------------------------------

// CONFIGUTION
LOCAL countdownTime IS 10. // Seconds to count down from before launch.
LOCAL destructAlt IS 30000. //  Science data wont be collected below this altitude -> safe destruct altitude to prevent ground impact.
LOCAL useRadarAlt IS FALSE. // Set to true to use radar altitude for destruct, false for sea level altitude. Radar accurate but less stable.
// --------------------------------------------------------------

// STARTUP
initalizeProgram().
//initalizeBereshit(electricChargeLevel, shipVariant). // Checks for electric charge and logs startup messages.
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
armAltitudeDetonation(destructAlt, useRadarAlt).
logMessage("Altitude safety detonator armed.", "warning", TRUE, FALSE, TRUE).
// --------------------------------------------------------------

// HOLD PROGRAM
WAIT UNTIL FALSE.
// --------------------------------------------------------------