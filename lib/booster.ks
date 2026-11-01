// EXPLAINATION
// * Booster ignition and separation, lit before the main engine or with it
// --------------------------------------------------------------

// MAIN FUNCTION
// Handles main engine ignition and booster separation
DECLARE FUNCTION armBoosterSeperation {
    DECLARE PARAMETER boosterTag IS "R103".
    DECLARE PARAMETER separatorTag IS "TR-8A".
    DECLARE PARAMETER mainEngineTag IS "U-1250".
    DECLARE PARAMETER preigniteMainThreshold IS 40.   // % booster fuel
    DECLARE PARAMETER separationBoosterPercentage IS 3.9.   // % booster fuel

    LOCAL boosterSeparation IS FALSE.
    LOCAL totalBoosters IS SHIP:PARTSTAGGED(boosterTag):LENGTH.
    //LOCAL boosterSeparationThreshold IS separationBoosterPercentage.// * 1.5. // 1.5x shutdown to prevent dry separation instability.

    // Resolved up front so Trigger B only fires actions
    LOCAL separatorModules IS resolveTaggedActionModules(separatorTag, "decouple").

    // Phase "main" means lit together, skips Trigger A
    IF flightData["phase"] <> "main" {
        SET flightData["phase"] TO "booster".
    }.
    WAIT 0.5.

    LOCAL ignitedCount IS countBoosterIgnitions(boosterTag).
    logMessage("Booster ignition: " + ignitedCount + "/" + totalBoosters + " ignited.", "info", TRUE, FALSE, TRUE).

    // Partial ignition is loss of control, abort the flight.
    IF ignitedCount > 0 AND ignitedCount < totalBoosters {

        logMessage("Partial booster failure detected. Loss of control has occurred.", "critical", TRUE, TRUE, TRUE).
        logMessage("Safety self-destruction now imminent.", "warning", TRUE, FALSE, TRUE).
        selfDestruct("Partial booster failure", 2).
    }.

    WHEN TRUE THEN {  
        LOCAL boosterPercent IS getResourcePercent("", boosterTag). // Booster fuel fill % found by tag; no resource name needed.
        // Main engine ignition and booster separation sequence.
        // Trigger A: lights main engine just before booster burnout
        IF flightData["phase"] = "booster" AND boosterPercent <= preigniteMainThreshold  {
           SET flightData["phase"] TO "main".
            logMessage("Main engine ignition.", "alert", TRUE, FALSE, TRUE).
            LOCAL mainIgnitionModules IS resolveTaggedActionModules(mainEngineTag, "activate engine").
            igniteResolvedModules(mainIgnitionModules, "activate engine").
        }.

        // Trigger B: drops boosters at low fuel
        IF flightData["phase"] = "main" AND boosterPercent <= separationBoosterPercentage {
            logMessage("Booster separation.", "alert", TRUE, FALSE, TRUE).
            igniteResolvedModules(separatorModules, "decouple").
            SET boosterSeparation TO TRUE.
            logMessage("Boosters separated.", "warning", TRUE, TRUE, TRUE).
        }.

        // Run until separation is done.
        IF NOT boosterSeparation {
            PRESERVE.
        }.
        //WAIT UNTIL boosterSeparation.
    }.
}.
// --------------------------------------------------------------