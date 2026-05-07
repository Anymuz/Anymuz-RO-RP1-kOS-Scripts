RUNONCEPATH("0:/lib/logging.ks").
RUNONCEPATH("0:/lib/audio.ks").

logBreaker("audio test session").
logMessage("Loading audio driver for testing.", "test", TRUE, FALSE, TRUE).
setupAudio("#", TRUE).
setLogToShipTime("MS", TRUE).
logMessage("Alarm stop test: In 3 seconds alarm will play indefinitely until stopped.", "test", TRUE, FALSE, TRUE).
WAIT 3.
playEngineFailureAlarm().
logMessage("Alarm playing. Press  default key  '#' to stop alarm.", "test", TRUE, FALSE, TRUE).
logMessage("If alarm doesn't stop, use CTRL + C to terminate test.", "test", TRUE, FALSE, TRUE).
WAIT UNTIL FALSE.
