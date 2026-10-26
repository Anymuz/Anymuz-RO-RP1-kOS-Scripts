// 0:/lib/logging.ks
// Logging utility functions.

GLOBAL logConfig IS LEXICON().
SET logConfig["timestamp"] TO TRUE.
SET logConfig["timeStyle"] TO "DHMS".
SET logConfig["writeFile"] TO TRUE.
SET logConfig["logFile"] TO "archive:/logs/flightlog.txt".
SET logConfig["startTime"] TO 0.

// Pointless but makes code look nice lol
DECLARE FUNCTION skipLine {
    DECLARE PARAMETER lines IS 1.
    FROM { LOCAL index IS 0. } UNTIL index >= lines STEP { SET index TO index + 1. } DO {
        PRINT " ".
    }.
}.

// Pads single digit numbers with a leading zero for consistent time formatting.
DECLARE FUNCTION pad2 {
    DECLARE PARAMETER number.
    SET number TO FLOOR(number).

    IF number < 10 {
        RETURN "0" + number.
    }.

    RETURN "" + number.
}.


DECLARE FUNCTION formatTime {
    DECLARE PARAMETER totalSeconds.
    DECLARE PARAMETER style IS "MS".

    SET style TO style:TOUPPER().
    SET totalSeconds TO FLOOR(totalSeconds).

    IF style = "MS" {
        LOCAL minutes IS FLOOR(totalSeconds / 60).
        LOCAL seconds IS totalSeconds - (minutes * 60).

        RETURN pad2(minutes) + ":" + pad2(seconds).
    }.

    IF style = "HMS" {
        LOCAL hours IS FLOOR(totalSeconds / 3600).
        LOCAL remaining IS totalSeconds - (hours * 3600).
        LOCAL minutes IS FLOOR(remaining / 60).
        LOCAL seconds IS remaining - (minutes * 60).

        RETURN pad2(hours) + ":" + pad2(minutes) + ":" + pad2(seconds).
    }.

    IF style = "DHMS" {
        LOCAL days IS FLOOR(totalSeconds / 86400).
        LOCAL remaining IS totalSeconds - (days * 86400).
        LOCAL hours IS FLOOR(remaining / 3600).

        SET remaining TO remaining - (hours * 3600).

        LOCAL minutes IS FLOOR(remaining / 60).
        LOCAL seconds IS remaining - (minutes * 60).

        RETURN days + ":" + pad2(hours) + ":" + pad2(minutes) + ":" + pad2(seconds).
    }.

    RETURN "" + totalSeconds.
}.

DECLARE FUNCTION getLogTime {
    RETURN TIME:SECONDS - logConfig["startTime"].
}.

DECLARE FUNCTION buildLogLine {
    DECLARE PARAMETER message.
    DECLARE PARAMETER messageType IS "info".
    DECLARE PARAMETER showTime IS TRUE.

    SET message TO message:TOUPPER().
    SET messageType TO messageType:TOUPPER().

    IF NOT message:ENDSWITH(".") {
        SET message TO message + ".".
    }.

    LOCAL output IS "[" + messageType + "] " + message.

    IF showTime {
        SET output TO "(" + formatTime(getLogTime(), logConfig["timeStyle"]) + ") " + output.
    }.

    RETURN output.
}.


DECLARE FUNCTION writeLogFile {
    DECLARE PARAMETER line.

    IF logConfig["writeFile"] {
        LOG line TO logConfig["logFile"].
    }.
}.


DECLARE FUNCTION playLogSound {
    DECLARE PARAMETER messageType.

    SET messageType TO messageType:TOUPPER().

    IF messageType = "CRITICAL" {
        playCriticalSound().
    } ELSE IF messageType = "WARNING" {
        playWarningSound().
    } ELSE IF messageType = "ALERT" {
        playAlertSound().
    } ELSE {
        RETURN.
    }.
}.


DECLARE FUNCTION logMessage {
    DECLARE PARAMETER message.
    DECLARE PARAMETER messageType IS "info".
    DECLARE PARAMETER consoleTimestamp IS TRUE.
    DECLARE PARAMETER playSound IS FALSE.
    DECLARE PARAMETER outputToConsole IS TRUE.

    IF playSound {
        playLogSound(messageType).
    }.

    LOCAL consoleOutput IS buildLogLine(message, messageType, consoleTimestamp AND logConfig["timestamp"]).
    LOCAL fileOutput IS buildLogLine(message, messageType, TRUE).

    IF outputToConsole {
        PRINT consoleOutput.
    }.

    writeLogFile(fileOutput).
}.

DECLARE FUNCTION setLogToShipTime {
    DECLARE PARAMETER timeStyle IS "MS".
    DECLARE PARAMETER outputToConsole IS FALSE.

    logMessage("Log switching to ship time", "log", TRUE, FALSE, outputToConsole).

    SET logConfig["startTime"] TO TIME:SECONDS.
    SET logConfig["timeStyle"] TO timeStyle.

    logMessage("Ship time active", "log", TRUE, FALSE, outputToConsole).
}.

DECLARE FUNCTION setLogToLaunchTime {
    DECLARE PARAMETER timeStyle IS "MS".
    DECLARE PARAMETER outputToConsole IS FALSE.

    // Logged using the previous time reference.
    logMessage("Log switching to launch time", "log", TRUE, FALSE, outputToConsole).

    SET logConfig["startTime"] TO TIME:SECONDS.
    SET logConfig["timeStyle"] TO timeStyle.

    // Logged using launch elapsed time.
    logMessage("Launch time active", "log", TRUE, FALSE, outputToConsole).
}.

DECLARE FUNCTION logBreaker {
    DECLARE PARAMETER title IS "NEW LOG SESSION".

    SET title TO title:TOUPPER().

    writeLogFile(" ").
    writeLogFile("--------------------------------------------------").
    writeLogFile("--------------[" + title + "]--------------").
    writeLogFile("--------------------------------------------------").
    writeLogFile(" ").
}.