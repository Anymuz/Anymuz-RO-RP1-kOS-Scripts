setupAudio().
logMessage("Attempting boot: " + SHIP:NAME + ".", "system", TRUE, FALSE, TRUE).
// Determine series from name with "-" as separator, if no separator assume not part of series and set series to vessel name.
LOCAL fullVesselName IS SHIP:NAME.
LOCAL series is FALSE.

IF SHIP:NAME:CONTAINS("-") {
    SET series TO SHIP:NAME:SPLIT("-")[0].
    logMessage("Detected series: " + series:TOUPPER() + ".", "system", TRUE, FALSE, TRUE).
}.

IF NOT series {
    SET shipFile TO "0:/ships/" + fullVesselName + ".ks".
} ELSE {
    SET shipFile TO "0:/ships/" + series:TOLOWER() + "/" + fullVesselName + ".ks".
}.

logMessage("Booting from: " + shipFile + ".", "system", TRUE, FALSE, TRUE).

IF EXISTS(shipFile) {
    logMessage("Boot successful: " + shipFile + ".", "system", TRUE, FALSE, TRUE).
    logBreaker("New session: " + SHIP:NAME).
    RUNPATH(shipFile).
} ELSE {
    logMessage("Boot failed: " + shipFile + ".", "critical", TRUE, TRUE, TRUE).
    logMessage("Terminated, no valid boot script found.", "critical", TRUE, FALSE, TRUE).
    skipLine().
    PRINT "[LOADING EXIT INFORMATION WITH INSTRUCTIONS]".
    RUNPATH("0:/system/failureInfo.ks").
}.
