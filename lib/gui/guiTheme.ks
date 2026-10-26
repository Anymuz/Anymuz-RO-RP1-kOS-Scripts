// GUI THEME
// Colours, sizes, and rich-text helpers. See docs/lib/gui/guiTheme.md.
// --------------------------------------------------------------

// THEME CONFIGURATION
// Colours are rich-text hex strings (RRGGBB or RRGGBBAA), consumed by colorText().
// Palette matched to the COSMIC FLEET logo: black field, scarlet red, silver-white.
GLOBAL guiTheme IS LEXICON().
SET guiTheme["titleSize"] TO 20.       // Window title font size.
SET guiTheme["headingSize"] TO 14.     // Section heading font size.
SET guiTheme["captionWidth"] TO 150.   // Fixed pixel width of the caption column in status rows.
SET guiTheme["captionColor"] TO "#b4bcc2".  // Silver - row captions (matches the logo's chrome).
SET guiTheme["valueColor"] TO "#ffffff".    // Crisp white - live readouts.
SET guiTheme["nominalColor"] TO "#66dd66".  // Green - all-good status.
SET guiTheme["alertColor"] TO "#ffcc33".    // Amber - warning status.
SET guiTheme["criticalColor"] TO "#ff4d4d". // Bright red - critical/alarm values.
SET guiTheme["accentColor"] TO "#e01e26".   // Scarlet - headings & title (the logo's signature red).
SET guiTheme["mutedColor"] TO "#6d757c".    // Cool grey - de-emphasised text.
// --------------------------------------------------------------

// RICH-TEXT HELPERS
// Wrap text in a colour tag. colorHex is a name ("orange") or hex ("#ffaa00ff").
DECLARE FUNCTION colorText {
    DECLARE PARAMETER text.
    DECLARE PARAMETER colorHex.

    RETURN "<color=" + colorHex + ">" + text + "</color>".
}.

// Wrap text in a bold tag.
DECLARE FUNCTION boldText {
    DECLARE PARAMETER text.

    RETURN "<b>" + text + "</b>".
}.

// Wrap text in a size tag.
DECLARE FUNCTION sizeText {
    DECLARE PARAMETER text.
    DECLARE PARAMETER fontSize.

    RETURN "<size=" + fontSize + ">" + text + "</size>".
}.

// Pre-styled window title string.
DECLARE FUNCTION titleText {
    DECLARE PARAMETER text.

    RETURN sizeText(boldText(text), guiTheme["titleSize"]).
}.

// Pre-styled section heading string.
DECLARE FUNCTION headingText {
    DECLARE PARAMETER text.

    RETURN colorText(sizeText(boldText(text), guiTheme["headingSize"]), guiTheme["accentColor"]).
}.
// --------------------------------------------------------------

// STATUS COLOURING
// Map a log-style status key to a theme colour so GUI values match console tags.
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

// Colour a value string according to a status key.
DECLARE FUNCTION statusText {
    DECLARE PARAMETER text.
    DECLARE PARAMETER statusKey.

    RETURN colorText(text, statusColor(statusKey)).
}.

// Build a fixed-width text progress bar, e.g. "[####------]" (kOS has no native
// bar/dial widget). pct is 0..100 (clamped); cells is the bar width in characters.
// Returns a plain string - wrap it in statusText(...) to colour it, and set it into
// a label with setWidgetText(). Swap the "#"/"-" glyphs below for block characters
// ("█"/"░") if you prefer a solid gauge look.
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

