// EXPLAINATION
// Entry point, sets up globals and libraries.
// --------------------------------------------------------------

// SHIP NAME
// WAIT UNTIL SHIP:UNPACKED.
// WAIT 2.
RUNONCEPATH("0:/lib/logging.ks").
logBreaker("Starting New Session").

// Series and variant from the name
GLOBAL shipName IS SHIP:NAME. // Used in logging and telemetry
LOCAL shipNameParts IS shipName:SPLIT("-").
GLOBAL shipSeries IS shipNameParts[0].

// Variant, if any
IF shipNameParts:LENGTH > 1 {
    GLOBAL shipVariant IS shipNameParts[1].
} ELSE {
    GLOBAL shipVariant IS "N/A".
}.
// --------------------------------------------------------------

// GLOBAL STATE
//logMessage(message, messageType, consoleTimestamp, playSound, outputToConsole).

// Each ship script needs these
GLOBAL flightData IS LEXICON().
SET flightData["maxVelocity"] TO 0.
SET flightData["maxVelocityAlt"] TO 0.
SET flightData["apogeeAlt"] TO 0.
SET flightData["apogeeVelocity"] TO 0.
SET flightData["descentCaptured"] TO FALSE.
SET flightData["phase"] TO "prelaunch".
SET flightData["maxApoapsis"] TO 0.
SET flightData["maxApoapsisAlt"] TO 0.
SET flightData["launchGeo"] TO SHIP:GEOPOSITION. // Launch site
logMessage("Global state initialized.", "system", TRUE, FALSE, TRUE).
// --------------------------------------------------------------

// LIBRARIES
// Utils first
RUNONCEPATH("0:/lib/utils.ks").
RUNONCEPATH("0:/lib/resources.ks").
RUNONCEPATH("0:/lib/parts.ks").
logMessage("Core function libraries loaded.", "system", TRUE, FALSE, TRUE).

// Audio, call setupAudio() in the ship script
RUNONCEPATH("0:/lib/audio.ks")..
logMessage("Core audio libraries loaded.", "system", TRUE, FALSE, TRUE).
// --------------------------------------------------------------

// SHIP SCRIPT
RUNPATH("0:/system/loadShip.ks"). 
// --------------------------------------------------------------