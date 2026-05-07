// WAIT UNTIL SHIP:UNPACKED.
// WAIT 2.
RUNONCEPATH("0:/lib/logging.ks").
logBreaker("Starting New Session").

GLOBAL shipName IS SHIP:NAME. // Set this to the name of the ship, used for logging and telemetry messages.
LOCAL shipNameParts IS shipName:SPLIT("-").
GLOBAL shipSeries IS shipNameParts[0].

IF shipNameParts:LENGTH > 1 {
    GLOBAL shipVariant IS shipNameParts[1].
} ELSE {
    GLOBAL shipVariant IS "N/A".
}.

//logMessage(message, messageType, consoleTimestamp, playSound, outputToConsole).
// message            Text to log/output.
// messageType        Type shown in [ ], automatically uppercased.
// consoleTimestamp   TRUE = show timestamp in console. FALSE = no console timestamp.
// playSound          TRUE = play short alert sound if messageType supports it.
// outputToConsole    TRUE = print to terminal. FALSE = log file only.

// INITIALISE GLOBAL STATE - Each ship script must have these for other functions to work properly.
GLOBAL flightData IS LEXICON().
SET flightData["maxVelocity"] TO 0.
SET flightData["maxVelocityAlt"] TO 0.
SET flightData["apogeeAlt"] TO 0.
SET flightData["apogeeVelocity"] TO 0.
SET flightData["descentCaptured"] TO FALSE.
SET flightData["phase"] TO "prelaunch".
SET flightData["maxApoapsis"] TO 0.
SET flightData["maxApoapsisAlt"] TO 0.
logMessage("Global state initialized.", "system", TRUE, FALSE, TRUE).

// Import utils first to ensure helper functions are fully available.
RUNONCEPATH("0:/lib/utils.ks").
logMessage("Core function libraries loaded.", "system", TRUE, FALSE, TRUE).

// Makes audio available for the ship 
// remember to call setupAudio() in the main ship script to initialize the audio system.
RUNONCEPATH("0:/lib/audio.ks")..
logMessage("Core audio libraries loaded.", "system", TRUE, FALSE, TRUE).

// Loads the ship specific script.
RUNPATH("0:/system/loadShip.ks"). 