// Bereshit R1 launch script, uses library system for modular code that allows easy reuse.
RUNONCEPATH("0:/programs/bereshit.ks"). // Import ship specific functions and telemetry.

// Control key inputs.
//LOCAL launchKey IS "L". // Key to start the launch sequence.
//LOCAL boosterEmergencyKey IS "B". // Key to manually trigger booster separation.
//LOCAL destructKey IS "+". // Key to manually trigger destruct sequence, should only be used IN EMERGENCY SITUATIONS.

// Launch parameters.
LOCAL countdownTime IS 10. // Seconds to count down from before launch.
LOCAL destructAlt IS 30000. //  Science data wont be collected below this altitude -> safe destruct altitude to prevent ground impact.
LOCAL useRadarAlt IS FALSE. // Set to true to use radar altitude for destruct, false for sea level altitude. Radar accurate but less stable.

// Resource levels.
// LOCAL boosterFuelLevel IS 19.2. // Set this to the initial fuel level of the boosters.
// LOCAL propellantLevel IS 86.9. // Set this to the absolute fuel level (not percentage) for main engine.
// LOCAL oxidizerLevel IS 165.5. // Set this to the absolute oxidizer level (not percentage) for main engine.
// LOCAL pressurizerLevel IS 7953. // Set this to the absolute pressure level required for main engine.
// LOCAL ignitiantLevel IS 1. // Set this to the absolute level of the ignitiant for main engine, set to 0 if not used.
// LOCAL electricChargeLevel IS 50. // Set this to the absolute electric charge level of the ship.

// Thresholds for events.
// LOCAL boosterPreigniteMainThreshold IS 0.4. // tune this to a percentage (whole decimal form) of fuel remaining when booster ignition should occur, aim for 1-2 seconds before actual ignition for best results.   
// LOCAL boosterShutdownThreshold IS 0.039. // Set this to the estimated percentage (whole decimal form) of fuel remaining when booster shutdown will occure.
// LOCAL fuelThreshold IS 0.0588. // Set this to the estimatedd percentage (whole decimal form) of fuel remaining when engine cutoff.
// LOCAL mainEngineStartThreshold IS 0.13. // Set this to the estimated spool up time for the main engine, used for failure detection grace period after ignition.
// -----------------------------------

// Startup for electronics and telemetry.
//print electricChargeLevel.
initalizeBereshit(electricChargeLevel, shipVariant). // Checks for electric charge and logs startup messages.
// -----------------------------------

// Launch sequence 
initializeLaunch(). // Waits for user input to start the launch sequence.
countdownLaunch(countdownTime). // Counts down from specified time
launchShip(). // launches the ship and plays sound.
// -------------------

// Post-launch functions to monitor and control flight and handle events.
armBoosterSeperation(boosterType, boosterFuel, (boosterPreigniteMainThreshold*boosterFuelLevel), (boosterShutdownThreshold * boosterFuelLevel)).
logMessage("Booster separation charges armed.", "alert", TRUE, FALSE, TRUE).
trackFlightStats().
logMessage("Flight stats tracking online.", "online", TRUE, FALSE, TRUE).
monitorEngines(mainEngine, propellant, oxidizer, fuelThreshold, fuelTank, mainEngineStartThreshold).
logMessage("Engine monitoring active.", "online", TRUE, FALSE, TRUE).
armAltitudeDetonation(destructAlt, useRadarAlt).
logMessage("Altitude safety detonator armed.", "warning", TRUE, FALSE, TRUE).
// -----------------------------------

// Wait indefinitely to prevent exiting mid-flight.
WAIT UNTIL FALSE.
// -----------------------------------