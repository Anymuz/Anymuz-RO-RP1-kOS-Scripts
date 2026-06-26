// Import libraries for launch, tracking, booster control, destruct system, and downrange guidance.
RUNONCEPATH("0:/lib/launch.ks").
RUNONCEPATH("0:/lib/tracking.ks").
RUNONCEPATH("0:/lib/booster.ks").
RUNONCEPATH("0:/lib/detonation.ks").
RUNONCEPATH("0:/lib/downrange.ks").
RUNONCEPATH("0:/lib/parachute.ks").
RUNONCEPATH("0:/lib/staging.ks"). // Apogee staging trigger.

// Engine types and fuel tanks. 
// NOTE: THESE ARE NO LONGER SHARED VARIABLES, EACH SHIP SCRIPT MUST DEFINE THESE FOR THEMSELVES
GLOBAL mainEngine IS "39B".
GLOBAL avionicsCore IS "NEMC". // Set this to the part tag for the avionics core, used for electric charge checks, set to any non-existent tag if not using electric charge.
GLOBAL fuelTank IS "SFT".

// Resource types.
GLOBAL propellant IS "Ethanol75".
GLOBAL oxidizer IS "LqdOxygen".
GLOBAL oxidizer2 IS "HTP".

// Resource levels.
GLOBAL fuelThreshold IS 0.047. 
GLOBAL mainEngineStartThreshold IS 2.33.

LOCAL bmidbarAlarmStopKey IS "#".

GLOBAL propellantLevel IS sumPartResource(fuelTank, propellant). // Set this to the absolute fuel level (not percentage) for main engine.
GLOBAL oxidizerLevel IS sumPartResource(fuelTank, oxidizer). // Set this to the absolute oxidizer level (not percentage) for main engine.
GLOBAL electricChargeLevel IS sumPartResource(avionicsCore, "ElectricCharge"). // Set this to the absolute electric charge level of the ship.

// Logging setup.
SET logConfig["timestamp"] TO TRUE.
SET logConfig["writeFile"] TO TRUE.
SET logConfig["logFile"] TO "archive:/logs/" + shipName + "_flightlog.txt".

// Bmidbar is a separate class of rocket with its ownn telemetry and sensors.
DECLARE FUNCTION activateSystems {
    DECLARE PARAMETER seriesVariant IS "LR1".

    IF seriesVariant:TOUPPER() = "LR1" {
        logMessage("Activating telemetry for Bereshit LR1", "system", TRUE, FALSE, TRUE).
        AG1 ON.
        WAIT 0.5.
        logMessage("Sensors, telemetry and transmission are standby.", "online", TRUE, FALSE, TRUE).
        logMessage("Telemetry data and sensors ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } ELSE IF seriesVariant:TOUPPER() = "LR2" {
        logMessage("Activating camera for Bereshit LR2", "system", TRUE, FALSE, TRUE).
        AG1 ON.
        WAIT 0.5.
        logMessage("Reconnaissance camera is standby.", "online", TRUE, FALSE, TRUE).
        skipLine().
    } ELSE IF seriesVariant:TOUPPER() = "LR3" {
        logMessage("Activating telemetry for Bereshit LR3", "system", TRUE, FALSE, TRUE).
        AG1 ON.
        WAIT 0.5.
        logMessage("Sensors, telemetry and transmission are standby.", "online", TRUE, FALSE, TRUE).
        logMessage("Telemetry data and sensors ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } ELSE {
        logMessage("Unknown series variant for telemetry activation.", "warning", TRUE, TRUE, TRUE).
        logMessage("Telemetry activation failed, no sensors activated.", "warning", TRUE, FALSE, TRUE).
        skipLine().
    }.
}.

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
        logMessage("Audio systems updating.", "system", TRUE, FALSE, TRUE).
        armAlarmKeyStop(bmidbarAlarmStopKey).
        logMessage("Initalizing onboard systems", "system", TRUE, FALSE, TRUE).
        activateSystems(seriesVariant).
        startupMessage(electricChargeLevel).
        WAIT 0.1.
    }.
}.