// INITALIZATION
// logMessage("Booting Bereshit R1 script, as it adapts for R2 configuration.", "system", TRUE, FALSE, TRUE).
// RUNPATH("0:/ships/bereshit/Bereshit-R1.ks").

LOCAL copyExisting IS "Breshit-R1".
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