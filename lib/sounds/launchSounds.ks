// EXPLAINATION
// * Library for all launch related audio tones.
// --------------------------------------------------------------

// SOUND NOTES
DECLARE FUNCTION  getCountdownNote {
    RETURN NOTE(880, 0.15, 0.15, 1).
}. // Each second of the countdown

DECLARE FUNCTION getLaunchNote {
    RETURN NOTE(1400, 0.3, 0.3, 1).
}. // Note for liftoff
// -------------------------------------------------------------