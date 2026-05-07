// Import libraries for launch, tracking, booster control, destruct system, and downrange guidance.
RUNONCEPATH("0:/lib/launch.ks").
RUNONCEPATH("0:/lib/tracking.ks").
RUNONCEPATH("0:/lib/booster.ks").
RUNONCEPATH("0:/lib/detonation.ks").
RUNONCEPATH("0:/lib/downrange.ks").

// Engine types and fuel tanks. 
// NOTE: THESE ARE NO LONGER SHARED VARIABLES, EACH SHIP SCRIPT MUST DEFINE THESE FOR THEMSELVES TO 
// ALLOW FOR DIFFERENT CONFIGURATIONS.
//GLOBAL boosterType IS "R103".
GLOBAL mainEngine IS "39B".
GLOBAL avionicsCore IS "NEMC". // Set this to the part tag for the avionics core, used for electric charge checks, set to any non-existent tag if not using electric charge.
GLOBAL fuelTank IS "SFT".

// Resource types.
//GLOBAL boosterFuel IS "NGNC".
GLOBAL propellant IS "Ethanol75".
GLOBAL oxidizer IS "LqdOxygen".
GLOBAL oxidizer2 IS "HTP".
//GLOBAL ignitiant IS "Tonka250.".

GLOBAL fuelThreshold IS 0.047. 
GLOBAL mainEngineStartThreshold IS 2.33.

LOCAL bmidbarAlarmStopKey IS "#".

//GLOBAL boosterFuelLevel IS sumPartResource(boosterType, "Fuel"). // Set this to the initial fuel level of the boosters.
GLOBAL propellantLevel IS sumPartResource(fuelTank, propellant). // Set this to the absolute fuel level (not percentage) for main engine.
GLOBAL oxidizerLevel IS sumPartResource(fuelTank, oxidizer). // Set this to the absolute oxidizer level (not percentage) for main engine.
//GLOBAL pressurizerLevel IS sumPartResource(fuelTank, "Pressurizer"). // Set this to the absolute pressure level required for main engine.
//GLOBAL ignitiantLevel IS sumPartResource(mainEngine, "Ignitiant"). // Set this to the absolute level of the ignitiant for main engine, set to 0 if not used.
GLOBAL electricChargeLevel IS sumPartResource(avionicsCore, "ElectricCharge"). // Set this to the absolute electric charge level of the ship.
//GLOBAL electricChargeLevel IS 215. // Set this to the absolute electric cha

// Logging setup.
SET logConfig["timestamp"] TO TRUE.
SET logConfig["writeFile"] TO TRUE.
SET logConfig["logFile"] TO "archive:/logs/" + shipName + "_flightlog.txt".

DECLARE FUNCTION initalizeBmidbar {
    DECLARE PARAMETER electricChargeLevel IS 0.
    DECLARE PARAMETER seriesVariant IS "LR1".
    PRINT electricChargeLevel.
    IF shipSeries:TOUPPER() <> "BMIDBAR" {
        logMessage("Ship is not a BMIDBAR class rocket, check ship naming and script assignment.", "critical", TRUE, TRUE, TRUE).
        RETURN.
    }.

    IF electricChargeLevel <= 0 {
        logMessage("No electrical charge detected, check connections and battery levels.", "critical", TRUE, FALSE, TRUE).
        logMessage("Launch is not possible without electrical charge, aborting launch sequence.", "critical", TRUE, TRUE, TRUE).
        RETURN.
    } ELSE {
        WAIT 0.2.
        logBreaker("New Misssion: " + shipName).
        setLogToShipTime("MS", TRUE).
        logMessage("Ship systems initializing.", "system", TRUE, FALSE, TRUE).

        logMessage("Audio systems updating.", "system", TRUE, FALSE, TRUE).
        armAlarmKeyStop(bmidbarAlarmStopKey).
        WAIT 0.1.

        // logMessage("Telemetry and data acquisition starting.", "system", TRUE, FALSE, TRUE).
        // activateTelemetry(seriesVariant).
        // startupMessage(electricChargeLevel).
        // WAIT 0.2.
    }.
}.