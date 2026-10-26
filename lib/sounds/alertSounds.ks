// EXPLAINATION
// * This library defines alert single not tones for various types of console alert output
// --------------------------------------------------------------

// INITALIZATION
RUNONCEPATH ("0:/lib/audio.ks"). // Audio driver
// --------------------------------------------------------------

// ALERT NOTE SOUNDS
DECLARE FUNCTION getCriticalNote {
    RETURN NOTE(200, 0.5, 0.5, 1).
}. // Critical console log output

DECLARE FUNCTION getWarningNote {
    RETURN NOTE(400, 0.5, 0.5, 1).
}. // Less-urgent but serious warning

DECLARE FUNCTION getAlertNote{
    RETURN NOTE(600, 0.5, 0.5, 1).
} // Basic non-urgent but attention needing events.
// --------------------------------------------------------------
