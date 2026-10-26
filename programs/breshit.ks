// Default inputs for the Breshit family dashboard. Ship programs may override
// these values after loading this file and before starting the GUI.
GLOBAL breshitDefaults IS LEXICON(
    "launchCountdown", 10,
    "boosterPreigniteMainThreshold", 3,
    "ignitionSync", TRUE,
    "separationBoosterPercentage", 5,
    "remainingFuelPercentage", 5,
    "mainEngineStartThreshold", 3,
    "destructAlt", 30000,
    "useRadarAlt", FALSE,
    "hasManualDestruct", TRUE,
    "hasAutoDestruct", FALSE
).

GLOBAL boosterDecouplerTag IS "BOOSTER-DECOUPLER".
