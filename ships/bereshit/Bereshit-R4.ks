// INITALIZATION
RUNONCEPATH("0:/programs/"+ shipSeries:TOLOWER() +".ks").
// --------------------------------------------------------------

// CONFIGUTION
LOCAL countdownTime IS 10. // Seconds to count down from before launch.
LOCAL deployAlt IS 15000. 
LOCAL useRadarAlt IS FALSE. // Set to true to use radar altitude. Radar more accurate but less stable.
LOCAL parachuteType IS "V1-PARACHUTE". 
LOCAL fairingType IS "CHUTE-CASE". // set to any non-existent tag if not using fairings.
// --------------------------------------------------------------

// STARTUP
initalizeProgram().
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
armParachute(parachuteType, deployAlt, useRadarAlt, fairingType).
logMessage("Parachutes armed.", "warning", TRUE, FALSE, TRUE).
// --------------------------------------------------------------

// HOLD PROGRAM
WAIT UNTIL FALSE.
// --------------------------------------------------------------