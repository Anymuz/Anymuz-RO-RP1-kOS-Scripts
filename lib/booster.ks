// EXPLAINATION
// * Determines behaviour of solid boosters, depending on how launch is set up these either ignite
// * Before main engine (Trigger A) or same time as it (Skip to Trigger B)
// --------------------------------------------------------------

// MAIN FUNCTION
DECLARE FUNCTION armBoosterSeperation {
    DECLARE PARAMETER boosterTag IS "R103".
    DECLARE PARAMETER separatorTag IS "TR-8A".
    DECLARE PARAMETER mainEngineTag IS "U-1250".
    DECLARE PARAMETER preigniteMainThreshold IS 40.
    DECLARE PARAMETER separationBoosterPercentage IS 3.9.

    LOCAL boosterSeparation IS FALSE.
    LOCAL totalBoosters IS SHIP:PARTSTAGGED(boosterTag):LENGTH.
    //LOCAL boosterSeparationThreshold IS separationBoosterPercentage.// * 1.5. // 1.5x shutdown to prevent dry separation instability.

    // Resolved ahead of time so Trigger B has nothing but DOACTION calls left to do -
    // same straggler problem as engine ignition (see igniteResolvedModules), just for decouple.
    LOCAL separatorModules IS resolveTaggedActionModules(separatorTag, "decouple").

    // Respect the phase set by the launch function:
    // "main"  -> launchShip already lit main engine + boosters together; skip Trigger A (main ignition).
    // else   -> sequential booster-then-main flow; Trigger A will light the main engine.
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
        // Trigger A: light the main engine just before booster burnout (sequential flow only).
        IF flightData["phase"] = "booster" AND boosterPercent <= preigniteMainThreshold  {
           SET flightData["phase"] TO "main".
            logMessage("Main engine ignition.", "alert", TRUE, FALSE, TRUE).
            // Ignite by part tag rather than STAGE so this fires regardless of stage order.
            LOCAL mainIgnitionModules IS resolveTaggedActionModules(mainEngineTag, "activate engine").
            igniteResolvedModules(mainIgnitionModules, "activate engine").
        }.

        // Trigger B: drop spent boosters once fuel is below the safe-separation threshold.
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