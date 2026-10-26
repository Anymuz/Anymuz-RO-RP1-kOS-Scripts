// 0:lib/sounds/alarmSounds.ks
// This file defines alarm sounds for various critical events, such as impending detonation or system failures. These sounds are intended to play until manually stopped.

DECLARE FUNCTION getDetonationAlarm {
    set detonationAlarm to LIST().
    // detonationAlarm:ADD(NOTE(900, 0.15, 0.15, 1)).
    // detonationAlarm:ADD(NOTE(650, 0.15, 0.15, 1)).
    detonationAlarm:ADD(NOTE(1000, 0.20, 0.20, 1)).
    detonationAlarm:ADD(NOTE(700,  0.20, 0.20, 1)).
    detonationAlarm:ADD(NOTE(1000, 0.20, 0.20, 1)).
    detonationAlarm:ADD(NOTE(700,  0.20, 0.20, 1)).
    detonationAlarm:ADD(NOTE(400,  0.40, 0.40, 1)).
    RETURN detonationAlarm.
}.

DECLARE FUNCTION getEngineFailureAlarm {
    set engineFailureAlarm to LIST().
    // engineFailureAlarm:ADD(NOTE(750, 0.12, 0.12, 1)).
    // engineFailureAlarm:ADD(NOTE(450, 0.25, 0.25, 1)).
    engineFailureAlarm:ADD(NOTE(750, 0.12, 0.12, 1)).
    engineFailureAlarm:ADD(NOTE(0,   0.08, 0.08, 0)).
    engineFailureAlarm:ADD(NOTE(750, 0.12, 0.12, 1)).
    engineFailureAlarm:ADD(NOTE(0,   0.08, 0.08, 0)).
    engineFailureAlarm:ADD(NOTE(450, 0.25, 0.25, 1)).
    RETURN engineFailureAlarm.
}.