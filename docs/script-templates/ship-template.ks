// * Template for a ship script, copy or make folder of series name
// * Then save this file in format of [series]-[variant].ks in that folder
// * Comments starting with * are instructions to assist
// * Delete these lines before finalising program

// INITALIZATION
// * This is where the series-common configuration is loaded:
RUNONCEPATH("0:/programs/"+ shipSeries:TOLOWER() +".ks").
// * Unless using a pre-existing varient, do not comment out the line above
// * Parts and resources are often initalised in such shared scripts
// * Programs/[variant].ks must exist and define a "activateSystems()" function

// * For some ships, a pre-existing variant can be loaded (uncomment below):
// l ogMessage("Booting [ship name] script, as it adapts for this configuration.", "system", TRUE, FALSE, TRUE).
// LOCAL copyExisting IS "[existing variant name]".
// RUNPATH("0:/ships/" + shipSeries:TOLOWER() +"/" + copyExisting + ".ks").
// * Only in this case the rest of the script is not needed and lines 8 and 31 can be commented.

// * Adjust and uncomment to suit your needs then delete the other comments
// * Keeep the ------------------ separator and SECTION TITLE comments for readability.
// --------------------------------------------------------------

// CONFIGUTION
// * This is where parameters that feed into the functions can be set
// * for quick access and tuning, so largely depends on what functions
// * this ship will run. View docs to see what functions exist
// --------------------------------------------------------------

// STARTUP
 // * MUST BE CALLED UNLESS USING /ships/[variant]/[ship-script].ks AT INITALIZATION
InitalizeProgram().

// * Call other ship specific initalisations here
// --------------------------------------------------------------

// LAUNCH SEQUENCE
// * Functions that setup and begin launch
// --------------------------------------------------------------

// POST LAUNCH SYSTEMS
// * Functions to define behaviour after lift off
// --------------------------------------------------------------

// HOLD PROGRAM
// * The line below is needed to prevent the script stopping when 
// * systems may still be being monitored.
// * Only use it if not using /ships/[variant]/[ship-script].ks at initalization.

 WAIT UNTIL FALSE.
// --------------------------------------------------------------

// * End of instructions  remove comments with * including this one