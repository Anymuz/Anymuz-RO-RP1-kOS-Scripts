// INITALIZATION
LOCAL copyExisting IS "Bereshit-R1".
logMessage("Booting " +copyExisting + " script, as it adapts for this configuration.", "system", TRUE, FALSE, TRUE).
RUNPATH("0:/ships/" +shipSeries:TOLOWER() +"/" + copyExisting + ".ks").

//RUNONCEPATH("0:/programs/"+ shipSeries:TOLOWER() +".ks").
// --------------------------------------------------------------

// CONFIGUTION
// --------------------------------------------------------------

// STARTUP
// InitalizeProgram(). 
// --------------------------------------------------------------

// LAUNCH SEQUENCE
// --------------------------------------------------------------

// POST LAUNCH SYSTEMS
// --------------------------------------------------------------

// HOLD PROGRAM
// WAIT UNTIL FALSE.
// --------------------------------------------------------------