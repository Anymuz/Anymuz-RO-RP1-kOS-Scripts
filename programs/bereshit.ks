// 0:/programs/bereshit.ks

// Import libraries for launch, tracking, booster control, destruct system, and downrange guidance.
RUNONCEPATH("0:/lib/launch.ks").
RUNONCEPATH("0:/lib/tracking.ks").
RUNONCEPATH("0:/lib/booster.ks").
RUNONCEPATH("0:/lib/detonation.ks").
RUNONCEPATH("0:/lib/downrange.ks").

// Engine types and fuel tanks. 
// NOTE: THESE ARE NO LONGER SHARED VARIABLES, EACH SHIP SCRIPT MUST DEFINE THESE FOR THEMSELVES TO 
// ALLOW FOR DIFFERENT CONFIGURATIONS -- ACTUALLY I  MADE A NEW SHIP FAMILY SO THEY GO BACK HERE
GLOBAL boosterType IS "R103".
GLOBAL mainEngine IS "U-1250".
GLOBAL fuelTank IS "HPSFT".
GLOBAL avionicsCore is "TSAC-100". // Set this to the part tag for the avionics core, used for electric charge checks, set to any non-existent tag if not using electric charge.

// Resource types.
GLOBAL boosterFuel IS "NGNC".
GLOBAL propellant IS "Kerosene".
GLOBAL oxidizer IS "AK20".
GLOBAL pressurizer IS "Nitrogen".
GLOBAL ignitiant IS "Tonka250.".

GLOBAL boosterFuelLevel IS sumPartResource(boosterType, boosterFuel). // Set this to the initial fuel level of the boosters.
GLOBAL propellantLevel IS sumPartResource(fuelTank, propellant). // Set this to the absolute fuel level (not percentage) for main engine.
GLOBAL oxidizerLevel IS sumPartResource(fuelTank, oxidizer). // Set this to the absolute oxidizer level (not percentage) for main engine.
GLOBAL pressurizerLevel IS sumPartResource(fuelTank, pressurizer). // Set this to the absolute pressure level required for main engine.
GLOBAL ignitiantLevel IS sumPartResource(mainEngine, ignitiant). // Set this to the absolute level of the ignitiant for main engine, set to 0 if not used.
GLOBAL electricChargeLevel IS sumPartResource(avionicsCore, "ElectricCharge"). // Set this to the absolute electric charge level of the ship.

GLOBAL boosterPreigniteMainThreshold IS 0.4. // tune this to a percentage (whole decimal form) of fuel remaining when main engine ignition should occur, aim for 1-2 seconds before actual ignition for best results.   
GLOBAL boosterShutdownThreshold IS 0.039. // Set this to the estimated percentage (whole decimal form) of fuel remaining when booster shutdown will occure.
GLOBAL fuelThreshold IS 0.0588. // Set this to the estimatedd percentage (whole decimal form) of fuel remaining when engine cutoff.
GLOBAL mainEngineStartThreshold IS 0.13. // Set this to the estimated spool up time for the main engine, used for failure detection grace period after ignition.

LOCAL bereshitAlarmStopKey IS "#".

// Logging setup.
SET logConfig["timestamp"] TO TRUE.
SET logConfig["writeFile"] TO TRUE.
SET logConfig["logFile"] TO "archive:/logs/" + shipName + "_flightlog.txt".


// Functions specific to Bereshit classification sounding rockets.
DECLARE FUNCTION activateTelemetry {
    DECLARE PARAMETER seriesVariant IS "R1".

    IF seriesVariant:TOUPPER() = "R1" {
        logMessage("Activating telemetry for Bereshit R1", "system", TRUE, FALSE, TRUE).
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
    } ELSE IF seriesVariant:TOUPPER() = "R2" {
        logMessage("Activating telemetry for Bereshit R2", "system", TRUE, FALSE, TRUE).
        AG1 ON.
        WAIT 0.1.
        logMessage("Sensors, telemetry and transmission are standby.", "online", TRUE, FALSE, TRUE).
        logMessage("Telemetry data and sensors ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } ELSE {
        logMessage("Unknown series variant for telemetry activation.", "warning", TRUE, TRUE, TRUE).
        logMessage("Telemetry activation failed, no sensors activated.", "warning", TRUE, FALSE, TRUE).
        skipLine().
    }.
}.


DECLARE FUNCTION startupMessage {
    DECLARE PARAMETER electricChargeLevel IS 0.

    logMessage("Electrics are LIVE, systems are now running on internal power.", "alert", TRUE, TRUE, TRUE).
    // logMessage("Start launch ASAP to avoid excessive EC depletion.", "system", TRUE, FALSE, TRUE). // now Use luach clamp 
    logMessage("On startup this vehicle has: " +ROUND(electricChargeLevel, 2) + "KJ.", "system", TRUE, FALSE, TRUE).
    //logMessage("Manually ensure EC level is sufficient before launch.", "system", TRUE, FALSE, TRUE). // Not needed
    skipLine().
    WAIT 0.5.
}.


DECLARE FUNCTION initalizeBereshit {
    DECLARE PARAMETER electricChargeLevel IS 0.
    DECLARE PARAMETER seriesVariant IS "R1".
    print electricChargeLevel.
    IF shipSeries:TOUPPER() <> "BERESHIT" {
        logMessage("Ship is not a BERESHIT class rocket, check ship naming and script assignment.", "critical", TRUE, TRUE, TRUE).
        RETURN.
    }.

    IF electricChargeLevel <= 0 {
        logMessage("No electrical power feed, check connections and battery levels.", "critical", TRUE, FALSE, TRUE).
        logMessage("Operation impossible without power, possible false positive. Abort.", "critical", TRUE, TRUE, TRUE).
        RETURN.
    } ELSE {
        WAIT 0.2.
        logBreaker("New Misssion: " + shipName).
        setLogToShipTime("MS", TRUE).
        logMessage("Ship systems initializing.", "system", TRUE, FALSE, TRUE).

        logMessage("Audio systems updating.", "system", TRUE, FALSE, TRUE).
        armAlarmKeyStop(bereshitAlarmStopKey).
        WAIT 0.1.

        logMessage("Telemetry and data acquisition starting.", "system", TRUE, FALSE, TRUE).
        activateTelemetry(seriesVariant).
        startupMessage(electricChargeLevel).
        WAIT 0.2.
    }.
}.