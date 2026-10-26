RUNONCEPATH ("0:/lib/audio.ks").

DECLARE FUNCTION getCriticalNote {
    RETURN NOTE(200, 0.5, 0.5, 1).
}.

DECLARE FUNCTION getWarningNote {
    RETURN NOTE(400, 0.5, 0.5, 1).
}.

DECLARE FUNCTION getAlertNote{
    RETURN NOTE(600, 0.5, 0.5, 1).
}