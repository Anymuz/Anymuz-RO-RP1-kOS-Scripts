DECLARE FUNCTION armBoosterSeperation {
    DECLARE PARAMETER boosterTag IS "R103".
    DECLARE PARAMETER boosterFuelName IS "NGNC".
    DECLARE PARAMETER preigniteMainFuel IS 3.
    DECLARE PARAMETER boosterShutdownFuel IS 0.2.

    LOCAL boosterSeparation IS FALSE.
    LOCAL totalBoosters IS SHIP:PARTSTAGGED(boosterTag):LENGTH.
    LOCAL boosterSeparationLevel IS boosterShutdownFuel * 1.5. // 1.5x shutdown to prevent dry separation instability.

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
        LOCAL boosterFuel IS sumPartResource(boosterTag, boosterFuelName).
         // Main engine ignition and booster separation sequence.   
        // Trigger A: light the main engine just before booster burnout (sequential flow only).
        IF flightData["phase"] = "booster" AND boosterFuel <= preigniteMainFuel  {
           SET flightData["phase"] TO "main".
            logMessage("Main engine ignition.", "alert", TRUE, FALSE, TRUE).
            STAGE.
        }.

        // Trigger B: drop spent boosters once fuel is below the safe-separation threshold.
        IF flightData["phase"] = "main" AND boosterFuel <= boosterSeparationLevel {
            logMessage("Booster separation.", "alert", TRUE, FALSE, TRUE).
            //WAIT UNTIL STAGE:READY.
            STAGE.
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