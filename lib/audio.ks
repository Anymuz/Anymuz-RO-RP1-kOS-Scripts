// 0:/lib/audio.ks
// Library of functions to set up audio driver.

SET audioInitialized TO FALSE.
SET launchAudio TO FALSE.
SET alertAudio TO FALSE.
SET alarmSound TO FALSE.

GLOBAL alarmState IS LEXICON().
SET alarmState["active"] TO FALSE.
SET alarmState["name"] TO "".
SET alarmState["stopTime"] TO 0.


DECLARE FUNCTION loadLaunchAudio {
    SET launchAudio TO GETVOICE(0).
    SET launchAudio:WAVE TO "SINE".
    // Notes are defined in lib/sounds/launchSounds.ks
    RUNONCEPATH("0:/lib/sounds/launchSounds.ks").
}.


DECLARE FUNCTION loadAlertAudio {
    SET alertAudio TO GETVOICE(1).
    SET alertAudio:WAVE TO "SQUARE".
    // Notes are defined in lib/sounds/alertSounds.ks
    RUNONCEPATH("0:/lib/sounds/alertSounds.ks").
}.


DECLARE FUNCTION loadAlarms {
    SET alarmSound TO GETVOICE(2).
    SET alarmSound:WAVE TO "SAWTOOTH".
    SET alarmSound:LOOP TO TRUE.
    // Song is defined in lib/sounds/alarmSounds.ks
    RUNONCEPATH("0:/lib/sounds/alarmSounds.ks").
}.


DECLARE FUNCTION checkAudioInitialized {
    IF NOT audioInitialized {
        logMessage("Audio driver not initialized. Call setupAudio() before using audio functions.", "error", TRUE, FALSE, TRUE).
        RETURN FALSE.
    } ELSE {
        RETURN TRUE.
    }.
}.


DECLARE FUNCTION logAlarmStarted {
    DECLARE PARAMETER alarmName.
    DECLARE PARAMETER duration IS 0.

    SET alarmName TO alarmName:TOUPPER().

    SET alarmState["active"] TO TRUE.
    SET alarmState["name"] TO alarmName.
    SET alarmState["stopTime"] TO TIME:SECONDS + duration.

    IF duration > 0 {
        logMessage(alarmName + " sounding for " + FLOOR(duration) + " seconds", "alarm", TRUE, FALSE, FALSE).
    } ELSE {
        logMessage(alarmName + " sounding", "alarm", TRUE, FALSE, FALSE).
    }.
}.


DECLARE FUNCTION logAlarmStopped {
    DECLARE PARAMETER manualStop IS FALSE.

    IF alarmState["active"] {
        IF manualStop {
            logMessage(alarmState["name"] + " manually stopped", "alarm", TRUE, FALSE, FALSE).
        } ELSE {
            logMessage(alarmState["name"] + " stopped", "alarm", TRUE, FALSE, FALSE).
        }.

        SET alarmState["active"] TO FALSE.
        SET alarmState["name"] TO "".
        SET alarmState["stopTime"] TO 0.
    }.
}.


GLOBAL alarmStopKey IS "#".
GLOBAL alarmStopKeyArmed IS FALSE.

DECLARE FUNCTION armAlarmKeyStop {
    DECLARE PARAMETER keyName IS "#".

    // Change the active alarm stop key.
    SET alarmStopKey TO keyName.

    // Only create the listener once.
    IF NOT alarmStopKeyArmed {
        SET alarmStopKeyArmed TO TRUE.

        WHEN TERMINAL:INPUT:HASCHAR THEN {
            LOCAL keyPress IS TERMINAL:INPUT:GETCHAR().

            IF keyPress = alarmStopKey {
                stopAlarmSound(TRUE).
            }.

            PRESERVE.
        }.
    }.

    logMessage("Alarm stop key armed. Press '" + alarmStopKey + "' to stop alarms.", "audio", TRUE, FALSE, TRUE).
}.


DECLARE FUNCTION stopAlarmAfter {
    DECLARE PARAMETER seconds IS 5.

    LOCAL stopTime IS TIME:SECONDS + seconds.

    WHEN TRUE THEN {
        IF NOT alarmState["active"] {
            // Alarm was already manually stopped.
        } ELSE IF TIME:SECONDS >= stopTime {
            stopAlarmSound(FALSE).
        } ELSE {
            PRESERVE.
        }.
    }.
}.


DECLARE FUNCTION playCountdownSound {
    IF NOT checkAudioInitialized() RETURN.
    launchAudio:PLAY(getCountdownNote()).

}.


DECLARE FUNCTION playLaunchSound {
    IF NOT checkAudioInitialized() RETURN.
    launchAudio:PLAY(getLaunchNote()).
    logMessage("Playing launch audio.", "audio", TRUE, FALSE, FALSE).
}.


DECLARE FUNCTION playCriticalSound {
    IF NOT checkAudioInitialized() RETURN.
    alertAudio:PLAY(getCriticalNote()).
    logMessage("Playing critical alert audio.", "audio", TRUE, FALSE, FALSE).
}.


DECLARE FUNCTION playWarningSound {
    IF NOT checkAudioInitialized() RETURN.
    alertAudio:PLAY(getWarningNote()).
    logMessage("Playing warning alert audio.", "audio", TRUE, FALSE, FALSE).
}.


DECLARE FUNCTION playAlertSound {
    IF NOT checkAudioInitialized() RETURN.
    alertAudio:PLAY(getAlertNote()).
    logMessage("Playing alert audio.", "audio", TRUE, FALSE, FALSE).
}.


// Alarm functions. These loop until stopped with user input from armAlarmKeyStop().
// If you want an alarm to play only for set duration provide the duration parameter.
DECLARE FUNCTION playDetonationAlarm {
    DECLARE PARAMETER duration IS 0.

    IF NOT checkAudioInitialized() RETURN.

    stopAlarmSound(FALSE). // Ensure detonation alarm sounds even if another alarm is currently playing.
    alarmSound:PLAY(getDetonationAlarm()).
    logAlarmStarted("detonation", duration).

    IF duration > 0 {
        stopAlarmAfter(duration).
    }.
}.


DECLARE FUNCTION playEngineFailureAlarm {
    DECLARE PARAMETER duration IS 0.

    IF NOT checkAudioInitialized() RETURN.

    stopAlarmSound(FALSE). // Ensure engine failure alarm sounds even if another alarm is currently playing.
    alarmSound:PLAY(getEngineFailureAlarm()).
    logAlarmStarted("engine failure", duration).

    IF duration > 0 {
        stopAlarmAfter(duration).
    }.
}.


DECLARE FUNCTION stopAlarmSound {
    DECLARE PARAMETER manualStop IS FALSE.

    IF NOT checkAudioInitialized() RETURN.

    alarmSound:STOP().
    logAlarmStopped(manualStop).
}.


DECLARE FUNCTION testAlertAudio {
    IF NOT checkAudioInitialized() RETURN.
    skipLine().
    logMessage("Alert audio.", "test", TRUE, FALSE, TRUE).
    WAIT 0.5.

    logMessage("Playing critical sound.", "test", TRUE, FALSE, TRUE).
    playCriticalSound().
    WAIT 2.

    logMessage("Playing warning sound.", "test", TRUE, FALSE, TRUE).
    playWarningSound().
    WAIT 2.

    logMessage("Playing alert sound.", "test", TRUE, FALSE, TRUE).
    playAlertSound().
    WAIT 2.

    logMessage("Completed alert audio test.", "test", TRUE, FALSE, TRUE).
    skipLine().
}.


DECLARE FUNCTION testLaunchAudio {
    IF NOT checkAudioInitialized() RETURN.

    skipLine().
    logMessage("Launch audio.", "test", TRUE, FALSE, TRUE).
    WAIT 0.5.

    logMessage("Playing countdown sound.", "test", TRUE, FALSE, TRUE).
    playCountdownSound().
    WAIT 2.

    logMessage("Playing launch sound.", "test", TRUE, FALSE, TRUE).
    playLaunchSound().
    WAIT 2.

    logMessage("Completed launch audio test.", "test", TRUE, FALSE, TRUE).
    skipLine().
}.


DECLARE FUNCTION testAlarms {
    DECLARE PARAMETER duration IS 3.

    IF NOT checkAudioInitialized() RETURN.

    skipLine().
    logMessage("Detonation alarm.", "test", TRUE, FALSE, TRUE).
    WAIT 0.5.

    logMessage("Playing detonation alarm.", "test", TRUE, FALSE, TRUE).
    playDetonationAlarm(duration).
    WAIT duration.

    logMessage("Stopped detonation alarm.", "test", TRUE, FALSE, TRUE).
    WAIT 0.5.

    logMessage("Engine failure alarm.", "test", TRUE, FALSE, TRUE).
    WAIT 0.5.

    logMessage("Playing engine failure alarm.", "test", TRUE, FALSE, TRUE).
    playEngineFailureAlarm(duration).
    WAIT duration.

    logMessage("Stopped engine failure alarm.", "test", TRUE, FALSE, TRUE).
    WAIT 0.5.

    logMessage("Completed alarm tests.", "test", TRUE, FALSE, TRUE).
    skipLine().
}.


DECLARE FUNCTION fullAudioTest {
    DECLARE PARAMETER alarmDuration IS 5.

    IF NOT checkAudioInitialized() RETURN.

    skipLine().
    logMessage("Full audio test.", "test", TRUE, FALSE, TRUE).
    WAIT 0.5.

    testAlertAudio().
    WAIT 0.5.

    testLaunchAudio().
    WAIT 0.5.

    testAlarms(alarmDuration).
    WAIT 0.5.

    logMessage("Completed full audio test.", "test", TRUE, FALSE, TRUE).
    skipLine().
}.


DECLARE FUNCTION setupAudio {
    DECLARE PARAMETER stopAlarmKey IS "#". // Key to stop alarm sounds when they are playing, set in armAlarmKeyStop().
    DECLARE PARAMETER testAudio IS FALSE. // Set to true to run audio tests after setup.

    skipLine().
    logMessage("Initializing audio driver.", "audio", TRUE, FALSE, TRUE).

    loadLaunchAudio().
    WAIT 0.05.
    logMessage("Launch audio loaded.", "audio", TRUE, FALSE, TRUE).

    loadAlertAudio().
    WAIT 0.05.
    logMessage("Alert audio loaded.", "audio", TRUE, FALSE, TRUE).

    loadAlarms().
    WAIT 0.05.
    logMessage("Alarm audio loaded.", "audio", TRUE, FALSE, TRUE).

    SET audioInitialized TO TRUE.
    WAIT 0.05.

    armAlarmKeyStop(stopAlarmKey).
    WAIT 0.05.

    logMessage("Audio driver online.", "audio", TRUE, FALSE, TRUE).

    IF testAudio {
        fullAudioTest().
    } ELSE {
        skipLine().
    }.
}.

// Do not use this unless you know exactly why you need to bypass audio setup.
DECLARE FUNCTION bypassAudioSetup {
    SET audioInitialized TO TRUE.
}.