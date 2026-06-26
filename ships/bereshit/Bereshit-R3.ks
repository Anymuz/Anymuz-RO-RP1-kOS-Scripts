// INITALIZATION
LOCAL copyExisting IS "Bereshit-R1".
logMessage("Booting " +copyExisting + " script, as it adapts for this configuration.", "system", TRUE, FALSE, TRUE).
RUNPATH("0:/ships/" + shipSeries:TOLOWER() + "/" + copyExisting + ".ks").
// --------------------------------------------------------------

// CONFIGUTION
// --------------------------------------------------------------

// STARTUP
// --------------------------------------------------------------

// LAUNCH SEQUENCE
// --------------------------------------------------------------

// POST LAUNCH SYSTEMS
// --------------------------------------------------------------

// HOLD PROGRAM
// WAIT UNTIL FALSE.
// --------------------------------------------------------------