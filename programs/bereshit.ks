// LOCAL INITIALIZATION
LOCAL alarmStopKey IS "#". // Key to stop an alarm sound.
LOCAL type IS shipVariant:TOUPPER().  // Localised for readability.

// Logging setup.
SET logConfig["timestamp"] TO TRUE.
SET logConfig["writeFile"] TO TRUE.
SET logConfig["logFile"] TO "archive:/logs/" + shipName + "_flightlog.txt".
// --------------------------------------------------------------

// SERIES FUNCTION LIBRARIES
RUNONCEPATH("0:/lib/launch.ks").
RUNONCEPATH("0:/lib/tracking.ks").
RUNONCEPATH("0:/lib/booster.ks").
RUNONCEPATH("0:/lib/detonation.ks").
RUNONCEPATH("0:/lib/downrange.ks").
RUNONCEPATH("0:/lib/parachute.ks").
RUNONCEPATH("0:/lib/staging.ks"). 
// --------------------------------------------------------------

// SERIES CONFIGURATION
// Parts
GLOBAL boosterType IS "R103".
GLOBAL fuelTank IS "HPSFT".

// Resources
GLOBAL boosterFuel IS "NGNC".
GLOBAL propellant IS "Kerosene".
GLOBAL oxidizer IS "AK20".
GLOBAL pressurizer IS "Nitrogen".
GLOBAL ignitiant IS "Tonka250.".
 
 // Engine thresholds.
GLOBAL boosterPreigniteMainThreshold IS 0.4. // tune this to a percentage (whole decimal form) of fuel remaining when main engine ignition should occur, aim for 1-2 seconds before actual ignition for best results.   
GLOBAL boosterShutdownThreshold IS 0.039. // Set this to the estimated percentage (whole decimal form) of fuel remaining when booster shutdown will occure.
GLOBAL fuelThreshold IS 0.0588. // Set this to the estimatedd percentage (whole decimal form) of fuel remaining when engine cutoff.
GLOBAL mainEngineStartThreshold IS 0.13. // Set this to the estimated spool up time for the main engine, used for failure detection grace period after ignition.
// -------------------------------------------------------------


//  VARIENT GROUP CONFIGURATIONS
IF type = "R1" OR type = "R2"  {
    GLOBAL mainEngine IS "U-1250".
    GLOBAL avionicsCore IS "TSAC-100". // Set this to the part tag for the avionics core,
} ELSE IF type = "R3" {
    GLOBAL mainEngine IS "U-1700".
    GLOBAL avionicsCore IS "PWSA-45". 
} ELSE IF type = "R4" {
    GLOBAL mainEngine IS "U-1700".
    GLOBAL avionicsCore IS "TSAC-150". 
} ELSE IF type = "R5" {
    GLOBAL mainEngine IS "U-1700".
    GLOBAL avionicsCore IS "PWSA-75".
} ELSE {
    logMessage("Unknown Bereshit variant, check ship naming and script assignment.", "critical", TRUE, TRUE, TRUE).
    //RETURN.
}.
// --------------------------------------------------------------

// RESOURCE LEVELS
GLOBAL boosterFuelLevel IS sumPartResource(boosterType, boosterFuel). // Set this to the initial fuel level of the boosters.
GLOBAL propellantLevel IS sumPartResource(fuelTank, propellant). // Set this to the absolute fuel level (not percentage) for main engine.
GLOBAL oxidizerLevel IS sumPartResource(fuelTank, oxidizer). // Set this to the absolute oxidizer level (not percentage) for main engine.
GLOBAL pressurizerLevel IS sumPartResource(fuelTank, pressurizer). // Set this to the absolute pressure level required for main engine.
GLOBAL ignitiantLevel IS sumPartResource(mainEngine, ignitiant). // Set this to the absolute level of the ignitiant for main engine, set to 0 if not used.
GLOBAL electricChargeLevel IS sumPartResource(avionicsCore, "ElectricCharge"). // Set this to the absolute electric charge level of the ship.
// --------------------------------------------------------------

// Functions specific to Bereshit classification sounding rockets.
DECLARE FUNCTION activateSystems {
    // DECLARE PARAMETER seriesVariant IS type.
    logMessage("Activating systems for Bereshit " + type, "system", TRUE, FALSE, TRUE).
    
    IF type = "R1" {
        AG1 ON.
        WAIT 0.2.
        logMessage("Telemetry transmission.", "online", TRUE, FALSE, TRUE).
        WAIT 0.2.
        AG2 ON.
        WAIT 0.2.
        logMessage("Temperature sensor data.", "online", TRUE, FALSE, TRUE).
        AG3 ON.
        WAIT 0.2.
        logMessage("Pressure sensor data.", "online", TRUE, FALSE, TRUE).
        
        WAIT 0.2.
        logMessage("Telemetry data and sensors ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } 
    
    ELSE IF type = "R2"  OR type = "R3"  OR type = "R4" {
        AG1 ON.
        WAIT 0.1.
        logMessage("Sensors, telemetry and transmission are standby.", "online", TRUE, FALSE, TRUE).
        logMessage("Telemetry data and sensors ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } 
    
    ELSE IF type = "R5"  { //OR type = "R6" {
        AG1 ON.
        WAIT 0.1.
        logMessage("Biological experiment active.", "online", TRUE, FALSE, TRUE).
        WAIT 0.1.
        logMessage("Telemetry and transmission are standby.", "online", TRUE, FALSE, TRUE).
        WAIT 0.1.
        logMessage("Telemetry data ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } 
    
    ELSE {
        logMessage("Unknown series variant for telemetry activation.", "warning", TRUE, TRUE, TRUE).
        logMessage("Telemetry activation failed, no sensors activated.", "warning", TRUE, FALSE, TRUE).
        skipLine().
    }.
}.

// DECLARE FUNCTION initalizeBereshit {
//     // DECLARE PARAMETER electricChargeLevel IS 0.
//     // DECLARE PARAMETER seriesVariant IS type.
//     IF shipSeries:TOUPPER() <> "BERESHIT" {
//         logMessage("Ship is not a BERESHIT class rocket, check ship naming and script assignment.", "critical", TRUE, TRUE, TRUE).
//         RETURN.
//     }.

//     IF electricChargeLevel <= 0 {
//         logMessage("No electrical power feed, check connections and battery levels.", "critical", TRUE, FALSE, TRUE).
//         logMessage("Operation impossible without power, possible false positive. Abort.", "critical", TRUE, TRUE, TRUE).
//         RETURN.
//     } 
    
//     ELSE {
//         WAIT 0.2.
//         logBreaker("New Misssion: " + shipName).
//         setLogToShipTime("MS", TRUE).
//         logMessage("Audio systems updating.", "system", TRUE, FALSE, TRUE).
//         armAlarmKeyStop(alarmStopKey).
//         logMessage("Initalizing onboard systems", "system", TRUE, FALSE, TRUE).
//         activateSystems().
//         startupMessage(electricChargeLevel).
//         WAIT 0.1.
//     }.
// }.