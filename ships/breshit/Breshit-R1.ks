// INITIALIZATION
RUNONCEPATH("0:/programs/"+ shipSeries:TOLOWER() +".ks").
// --------------------------------------------------------------

// SHIP CONFIGUTION
// ** Local configuration values for this specific ship variant if required go here.
// --------------------------------------------------------------

// STARTUP
initalizeProgram().
registerBreshitSystems(). // Register the destruct system for GUI auto/manual arming.
startBreshitGui(shipName). // Build and show this family's one GUI.
// --------------------------------------------------------------

// LAUNCH SEQUENCE
initializeLaunch(). // Waits for a keypress or the GUI LAUNCH button.
countdownLaunch(userInputs["launchCountdown"]). // Counts down from runtime launch input.
launchShip(userInputs["ignitionSync"]). // launches the ship and plays sound.
// --------------------------------------------------------------

// POST LAUNCH SYSTEMS
armBoosterSeperation(boosterType, boosterSeperators, mainEngine, userInputs["boosterPreigniteMainThreshold"], userInputs["separationBoosterPercentage"]). // Automatic - fires too fast for manual control.
logMessage("Booster separation charges armed.", "alert", TRUE, FALSE, TRUE).
autoArmSystems(). // Arms the destruct system; the AUTOMATION tab decides if it actually fires.
logMessage("Automated systems armed (manual overrides respected).", "system", TRUE, FALSE, TRUE).
trackFlightStats().
logMessage("Flight stats tracking online.", "online", TRUE, FALSE, TRUE).
monitorEngines(mainEngine, userInputs["remainingFuelPercentage"], fuelTank, userInputs["mainEngineStartThreshold"]).
logMessage("Engine monitoring active.", "online", TRUE, FALSE, TRUE).
// --------------------------------------------------------------

// HOLD PROGRAM
WAIT UNTIL FALSE.
// --------------------------------------------------------------