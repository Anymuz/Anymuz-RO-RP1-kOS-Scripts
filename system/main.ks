RUNONCEPATH("0:/lib/logging.ks").
logBreaker("Starting New Session").

// Split the vessel name into family and variant.
GLOBAL shipName IS SHIP:NAME. // Set this to the name of the ship, used for logging and telemetry messages.
LOCAL shipNameParts IS shipName:SPLIT("-").
GLOBAL shipSeries IS shipNameParts[0].

IF shipNameParts:LENGTH > 1 {
    GLOBAL shipVariant IS shipNameParts[1].
} ELSE {
    GLOBAL shipVariant IS "N/A".
}.

// Shared telemetry state used by the flight libraries.
GLOBAL flightData IS LEXICON().
SET flightData["maxVelocity"] TO 0.
SET flightData["maxVelocityAlt"] TO 0.
SET flightData["apogeeAlt"] TO 0.
SET flightData["apogeeVelocity"] TO 0.
SET flightData["descentCaptured"] TO FALSE.
SET flightData["phase"] TO "prelaunch".
SET flightData["maxApoapsis"] TO 0.
SET flightData["maxApoapsisAlt"] TO 0.
SET flightData["launchGeo"] TO SHIP:GEOPOSITION. // Launch site captured on the pad for downrange tracking.
logMessage("Global state initialized.", "system", TRUE, FALSE, TRUE).

RUNONCEPATH("0:/lib/utils.ks").
RUNONCEPATH("0:/lib/resources.ks").
RUNONCEPATH("0:/lib/parts.ks").
logMessage("Core function libraries loaded.", "system", TRUE, FALSE, TRUE).

RUNONCEPATH("0:/lib/audio.ks")..
logMessage("Core audio libraries loaded.", "system", TRUE, FALSE, TRUE).

RUNPATH("0:/system/loadShip.ks").