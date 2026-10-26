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
RUNONCEPATH("0:/lib/science.ks").
RUNONCEPATH("0:/gui/breshit.ks"). // Series dashboard layout and panels (loads the  GUI library).
// --------------------------------------------------------------

// SERIES GLOBAL CONFIGURATION
// Parts
GLOBAL boosterType IS "R103".
GLOBAL fuelTank IS "HPSFT".
GLOBAL boosterSeperators IS "TR-8A".
GLOBAL launchClamp IS "LC-375".

// Immutable baseline defaults (the 'factory' settings):
GLOBAL launchCountdownDefault IS 10.
GLOBAL boosterPreigniteMainThreshold IS 40. // Booster fuel fill % remaining when the main engine should ignite; aim for 1-2 seconds before actual ignition for best results.
GLOBAL ignitionSync IS FALSE. // TRUE = main engine ignites sequentially at boosterPreigniteMainThreshold; FALSE = main + boosters ignite together at launch. Must match the craft's staging.
GLOBAL separationBoosterPercentage IS 5.0. // Booster fuel fill % remaining when booster shutdown/separation will occur.
GLOBAL remainingFuelPercentage IS 5.88. // Expected tank fill % remaining when the engine naturally cuts off (percentage form, not decimal).
GLOBAL mainEngineStartThreshold IS 0.13. // Set this to the estimated spool up time for the main engine, used for failure detection grace period after ignition.
GLOBAL destructAlt IS 40000. // Safe auto-destruct altitude (m), baseline for runtime tuning.
GLOBAL useRadarAlt IS FALSE. // Baseline auto-destruct altitude mode for runtime tuning.
// --------------------------------------------------------------


// VARIANT SPECIFIC CONFIGURATIONS
// Part identification: IG ship must have correct kOs tags assigned.
IF type = "R1" OR type = "R2"  {
    GLOBAL mainEngine IS "U-1250".  // Part tags must be consistent with expected values.
    GLOBAL avionicsCore IS "TSAC-80". 
    GLOBAL hasManualDestruct IS TRUE. // Manual self-destruct; 
    GLOBAL hasAutoDestruct IS TRUE. // Altitude auto-destruct.
    IF type = "R2" {
        // TODO: confirm this matches the exact in-game resource name for the sounding payload.
        SET payloadResourceNames TO LIST("SoundingPayload"). // Non-consumed; excluded from tank fill aggregates.
    }.
} ELSE IF type = "R3" {
    GLOBAL mainEngine IS "U-1700". // Upgraded Engine
    GLOBAL avionicsCore IS "PWSA-45". // Upgraded Avionics
    GLOBAL hasManualDestruct IS TRUE.
    GLOBAL hasAutoDestruct IS FALSE.
} ELSE IF type = "R4" {
    GLOBAL mainEngine IS "U-1700". 
    GLOBAL avionicsCore IS "TSAC-150". 
    GLOBAL hasManualDestruct IS TRUE.
    GLOBAL hasAutoDestruct IS FALSE.
} ELSE IF type = "R5" {
    GLOBAL mainEngine IS "U-1700".
    GLOBAL avionicsCore IS "PWSA-75". // More Advanced Avionics
    GLOBAL hasManualDestruct IS TRUE.
    GLOBAL hasAutoDestruct IS FALSE.
} ELSE { 
    logMessage("Unknown Breshit variant, check ship naming and script assignment.", "critical", TRUE, TRUE, TRUE).
    GLOBAL hasManualDestruct IS FALSE.
    GLOBAL hasAutoDestruct IS FALSE.
}.
// --------------------------------------------------------------

// MEASURE RESOURCE LEVELS
// Starting snapshot captured once at init: resource name -> LEXICON(amount, capacity, percent).
GLOBAL shipResources IS getResourceSummary(). // Auto-discovered: resource name -> LEXICON(amount, capacity, percent).
// --------------------------------------------------------------

// INITIALIZE/RESET RUNTIME INPUT VALUES
resetBreshitDefaults(). // Only call after global variable initialization.
// --------------------------------------------------------------

// SERIES SPECIFIC FUNCTIONS
// Activate systems based on variant type.
DECLARE FUNCTION activateSystems {
    logMessage("Activating Science Systems: Breshit " + type, "system", TRUE, FALSE, TRUE).
    IF type = "R1" {
        // With R1 varients have  different Action Groups for each system.
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
    } ELSE IF type = "R2"  OR type = "R3"  OR type = "R4" {
        // For R2, R3, and R4 variants have a single action group for all systems.
        AG1 ON.
        WAIT 0.1.
        logMessage("Sensors, telemetry and transmission are standby.", "online", TRUE, FALSE, TRUE).
        logMessage("Telemetry data and sensors ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } ELSE IF type = "R5"  { //OR type = "R6" {
        // The R5 has a biological experiment system that activates.
        AG1 ON.
        WAIT 0.1.
        logMessage("Biological experiment active.", "online", TRUE, FALSE, TRUE).
        WAIT 0.1.
        logMessage("Telemetry and transmission are standby.", "online", TRUE, FALSE, TRUE).
        WAIT 0.1.
        logMessage("Telemetry data ready to auto transmit.", "info", TRUE, FALSE, TRUE).
        skipLine().
    } ELSE {
        // Function will not activate systems for an unknown variant 
        logMessage("Unknown series variant for telemetry activation.", "warning", TRUE, TRUE, TRUE).
        logMessage("Telemetry activation failed, no sensors activated.", "warning", TRUE, FALSE, TRUE).
        skipLine().
    }.
}.

// Register live system callbacks for this variant to allow in-flight control.
DECLARE FUNCTION registerBreshitSystems {
    IF hasAutoDestruct {
        //auto-destruct variants use this
        registerSystem("Destruct", {
            armAltitudeDetonation( 
            // Callback returns for live inputs.
                { RETURN userInputs["destructAlt"]. },
                { RETURN userInputs["useRadarAlt"]. }
            ).
        }).
    }.
}.
// --------------------------------------------------------------

// DECLARE FUNCTION initalizeBreshit {
//     // DECLARE PARAMETER electricChargeLevel IS 0.
//     // DECLARE PARAMETER seriesVariant IS type.
//     IF shipSeries:TOUPPER() <> "BRESHIT" {
//         logMessage("Ship is not a BRESHIT class rocket, check ship naming and script assignment.", "critical", TRUE, TRUE, TRUE).
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
//         // activateSystems().
//         startupMessage(electricChargeLevel).
//         WAIT 0.1.
//     }.
// }.