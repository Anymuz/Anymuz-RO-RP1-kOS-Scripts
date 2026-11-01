// EXPLAINATION
// Colours, sizes and rich text helpers for the GUI
// --------------------------------------------------------------

// THEME CONFIGURATION
GLOBAL guiTheme IS LEXICON().
SET guiTheme["titleSize"] TO 20.
SET guiTheme["headingSize"] TO 14.
SET guiTheme["captionWidth"] TO 150.   // pixels
SET guiTheme["captionColor"] TO "#b4bcc2".  // Silver
SET guiTheme["valueColor"] TO "#ffffff".    // White
SET guiTheme["nominalColor"] TO "#66dd66".  // Green
SET guiTheme["alertColor"] TO "#ffcc33".    // Amber
SET guiTheme["criticalColor"] TO "#ff4d4d". // Red
SET guiTheme["accentColor"] TO "#e01e26".   // Scarlet
SET guiTheme["mutedColor"] TO "#6d757c".    // Grey
// --------------------------------------------------------------

// RICH-TEXT HELPERS
// Wraps text in colour tag
DECLARE FUNCTION colorText {
    DECLARE PARAMETER text.
    DECLARE PARAMETER colorHex.

    RETURN "<color=" + colorHex + ">" + text + "</color>".
}.

// Wraps text in bold tag
DECLARE FUNCTION boldText {
    DECLARE PARAMETER text.

    RETURN "<b>" + text + "</b>".
}.

// Wraps text in size tag
DECLARE FUNCTION sizeText {
    DECLARE PARAMETER text.
    DECLARE PARAMETER fontSize.

    RETURN "<size=" + fontSize + ">" + text + "</size>".
}.

// Window title style
DECLARE FUNCTION titleText {
    DECLARE PARAMETER text.

    RETURN sizeText(boldText(text), guiTheme["titleSize"]).
}.

// Section heading style
DECLARE FUNCTION headingText {
    DECLARE PARAMETER text.

    RETURN colorText(sizeText(boldText(text), guiTheme["headingSize"]), guiTheme["accentColor"]).
}.
// --------------------------------------------------------------

// STATUS COLOURING
// Status key to theme colour
DECLARE FUNCTION statusColor {
    DECLARE PARAMETER statusKey.

    SET statusKey TO statusKey:TOUPPER().

    IF statusKey = "CRITICAL" OR statusKey = "ERROR" {
        RETURN guiTheme["criticalColor"].
    }.
    IF statusKey = "WARNING" OR statusKey = "ALERT" OR statusKey = "ALARM" {
        RETURN guiTheme["alertColor"].
    }.
    IF statusKey = "NOMINAL" OR statusKey = "ONLINE" OR statusKey = "OK" {
        RETURN guiTheme["nominalColor"].
    }.

    RETURN guiTheme["valueColor"].
}.

// Colours text by status key
DECLARE FUNCTION statusText {
    DECLARE PARAMETER text.
    DECLARE PARAMETER statusKey.

    RETURN colorText(text, statusColor(statusKey)).
}.

// Text progress bar, pct 0..100
DECLARE FUNCTION barText {
    DECLARE PARAMETER pct.
    DECLARE PARAMETER cells IS 20.

    LOCAL clamped IS pct.
    IF clamped < 0 { SET clamped TO 0. }.
    IF clamped > 100 { SET clamped TO 100. }.

    LOCAL filled IS ROUND(cells * clamped / 100).
    LOCAL bar IS "".
    FROM { LOCAL i IS 0. } UNTIL i >= cells STEP { SET i TO i + 1. } DO {
        IF i < filled {
            SET bar TO bar + "#".
        } ELSE {
            SET bar TO bar + "-".
        }.
    }.
    RETURN "[" + bar + "]".
}.
// --------------------------------------------------------------

