// EXPLAINATION
// Window lifecycle, widget registry and timed refresh for the GUI
// --------------------------------------------------------------

// CONFIGURATION
GLOBAL guiConfig IS LEXICON().
SET guiConfig["x"] TO 350.             // pixels, negative = from right
SET guiConfig["y"] TO 250.             // pixels, negative = from bottom
SET guiConfig["width"] TO 440.         // pixels
SET guiConfig["refreshInterval"] TO 0.5. // seconds
SET guiConfig["logo"] TO "docs/images/flag".  // archive-relative PNG, no ".png"
SET guiConfig["logoMode"] TO "header". // "header", "background" or "off"
SET guiConfig["logoAlign"] TO "CENTER". // "LEFT", "CENTER" or "RIGHT"
SET guiConfig["logoWidth"] TO 360.     // pixels
SET guiConfig["logoHeight"] TO 220.    // pixels
SET guiConfig["background"] TO "".     // archive-relative PNG, "" = none
SET guiConfig["engineTag"] TO "U-1250". // Main engine tag
SET guiConfig["manualDestruct"] TO TRUE. // Shows the SELF DESTRUCT button
// --------------------------------------------------------------

// EDITABLE MISSION PARAMETERS
// Shared tunables, bind fields with guiAddParamField
GLOBAL guiParams IS LEXICON().
// --------------------------------------------------------------

// STATE
GLOBAL guiState IS LEXICON().
SET guiState["window"] TO 0.           // 0 when no window
SET guiState["created"] TO FALSE.
SET guiState["visible"] TO FALSE.
SET guiState["widgets"] TO LEXICON().
SET guiState["updaters"] TO LIST().
SET guiState["refreshInstalled"] TO FALSE.
SET guiState["refreshArmed"] TO FALSE.
SET guiState["nextRefresh"] TO 0.      // TIME:SECONDS
// --------------------------------------------------------------

// WINDOW LIFECYCLE
// Builds a fresh empty window
DECLARE FUNCTION createGuiWindow {
    DECLARE PARAMETER windowTitle IS "kOS MISSION CONTROL".
    DECLARE PARAMETER width IS guiConfig["width"].

    disposeGui().

    SET guiState["window"] TO GUI(width).
    SET guiState["created"] TO TRUE.
    SET guiState["widgets"] TO LEXICON().
    SET guiState["updaters"] TO LIST().

    SET guiState["window"]:X TO guiConfig["x"].
    SET guiState["window"]:Y TO guiConfig["y"].
    SET guiState["window"]:DRAGGABLE TO TRUE.

    // Background image
    LOCAL bgImage IS guiConfig["background"].
    IF bgImage = "" AND guiConfig["logoMode"] = "background" {
        SET bgImage TO guiConfig["logo"].
    }.
    IF bgImage <> "" {
        SET guiState["window"]:STYLE:BG TO bgImage.
    }.

    // Header logo, spacers either side to position it
    IF guiConfig["logo"] <> "" AND guiConfig["logoMode"] = "header" {
        LOCAL logoRow IS guiState["window"]:ADDHLAYOUT().
        IF guiConfig["logoAlign"] <> "LEFT" { guiSpacer(-1, logoRow). }.
        guiAddImage(logoRow, guiConfig["logo"], guiConfig["logoWidth"], guiConfig["logoHeight"]).
        IF guiConfig["logoAlign"] <> "RIGHT" { guiSpacer(-1, logoRow). }.
    }.

    LOCAL titleLabel IS guiState["window"]:ADDLABEL(titleText(windowTitle)).
    SET titleLabel:STYLE:ALIGN TO "CENTER".
    SET titleLabel:STYLE:HSTRETCH TO TRUE.

    RETURN guiState["window"].
}.

// Shows the window
DECLARE FUNCTION showGui {
    IF guiState["created"] {
        guiState["window"]:SHOW().
        SET guiState["visible"] TO TRUE.
    }.
}.

// Hides the window
DECLARE FUNCTION hideGui {
    IF guiState["created"] {
        guiState["window"]:HIDE().
        SET guiState["visible"] TO FALSE.
    }.
}.

// Destroys the window and clears widgets and updaters
DECLARE FUNCTION disposeGui {
    IF guiState["created"] {
        guiState["window"]:HIDE().
        guiState["window"]:DISPOSE().
    }.

    SET guiState["created"] TO FALSE.
    SET guiState["visible"] TO FALSE.
    SET guiState["window"] TO 0.
    SET guiState["widgets"] TO LEXICON().
    SET guiState["updaters"] TO LIST().
}.
// --------------------------------------------------------------

// WIDGET REGISTRY
// Stores a widget under a name
DECLARE FUNCTION registerWidget {
    DECLARE PARAMETER widgetName.
    DECLARE PARAMETER widget.

    SET guiState["widgets"][widgetName] TO widget.
    RETURN widget.
}.

// Sets text on a registered widget
DECLARE FUNCTION setWidgetText {
    DECLARE PARAMETER widgetName.
    DECLARE PARAMETER text.

    IF guiState["widgets"]:HASKEY(widgetName) {
        SET guiState["widgets"][widgetName]:TEXT TO text.
    }.
}.

// Adds a delegate run every refresh
DECLARE FUNCTION registerUpdater {
    DECLARE PARAMETER updater.

    guiState["updaters"]:ADD(updater).
}.
// --------------------------------------------------------------

// WIDGET FACTORIES
// Section heading label
DECLARE FUNCTION guiAddHeading {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER text.

    LOCAL headingLabel IS parentBox:ADDLABEL(headingText(text)).
    SET headingLabel:STYLE:HSTRETCH TO TRUE.
    SET headingLabel:STYLE:ALIGN TO "LEFT".
    RETURN headingLabel.
}.

// Image from archive PNG
DECLARE FUNCTION guiAddImage {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER imagePath.
    DECLARE PARAMETER width IS 96.
    DECLARE PARAMETER height IS 96.

    LOCAL picture IS parentBox:ADDLABEL("").
    SET picture:IMAGE TO imagePath.
    SET picture:STYLE:WIDTH TO width.
    SET picture:STYLE:HEIGHT TO height.
    SET picture:STYLE:ALIGN TO "CENTER".
    RETURN picture.
}.

// Caption and value row
DECLARE FUNCTION guiAddStatusRow {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER caption.
    DECLARE PARAMETER widgetName.
    DECLARE PARAMETER initialValue IS "--".

    LOCAL row IS parentBox:ADDHLAYOUT().

    LOCAL captionLabel IS row:ADDLABEL(colorText(caption, guiTheme["captionColor"])).
    SET captionLabel:STYLE:WIDTH TO guiTheme["captionWidth"].
    SET captionLabel:STYLE:ALIGN TO "LEFT".

    LOCAL valueLabel IS row:ADDLABEL(initialValue).
    SET valueLabel:STYLE:HSTRETCH TO TRUE.
    SET valueLabel:STYLE:ALIGN TO "RIGHT".

    registerWidget(widgetName, valueLabel).
    RETURN valueLabel.
}.

// Self updating bar row, delegate returns 0..100
DECLARE FUNCTION guiAddBar {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER caption.
    DECLARE PARAMETER valueDelegate.
    DECLARE PARAMETER cells IS 20.
    DECLARE PARAMETER warnBelow IS 40.
    DECLARE PARAMETER critBelow IS 15.

    LOCAL row IS parentBox:ADDHLAYOUT().

    LOCAL captionLabel IS row:ADDLABEL(colorText(caption, guiTheme["captionColor"])).
    SET captionLabel:STYLE:WIDTH TO guiTheme["captionWidth"].
    SET captionLabel:STYLE:ALIGN TO "LEFT".

    LOCAL barLabel IS row:ADDLABEL(barText(0, cells)).
    SET barLabel:STYLE:HSTRETCH TO TRUE.
    SET barLabel:STYLE:ALIGN TO "RIGHT".

    registerUpdater({
        LOCAL pct IS valueDelegate:CALL().
        LOCAL key IS "NOMINAL".
        IF pct < warnBelow { SET key TO "WARNING". }.
        IF pct < critBelow { SET key TO "CRITICAL". }.
        SET barLabel:TEXT TO statusText(barText(pct, cells) + " " + ROUND(pct, 0) + "%", key).
    }).

    RETURN barLabel.
}.

// Button with click delegate
DECLARE FUNCTION guiAddButton {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER text.
    DECLARE PARAMETER onClick.

    LOCAL button IS parentBox:ADDBUTTON(text).
    SET button:ONCLICK TO onClick.
    RETURN button.
}.

// Checkbox with toggle delegate
DECLARE FUNCTION guiAddToggle {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER text.
    DECLARE PARAMETER initialOn.
    DECLARE PARAMETER onToggle.

    LOCAL toggle IS parentBox:ADDCHECKBOX(text, initialOn).
    SET toggle:ONTOGGLE TO onToggle.
    RETURN toggle.
}.

// Button that only fires when ARM is ticked
DECLARE FUNCTION guiAddArmedAction {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER label.
    DECLARE PARAMETER onFire.

    LOCAL actionRow IS parentBox:ADDHLAYOUT().
    LOCAL armBox IS actionRow:ADDCHECKBOX("ARM", FALSE).
    LOCAL fireButton IS actionRow:ADDBUTTON(label).
    SET fireButton:ONCLICK TO {
        IF armBox:PRESSED {
            onFire:CALL().
            SET armBox:PRESSED TO FALSE.
        }.
    }.
    RETURN fireButton.
}.

// Number field bound to a lexicon key
DECLARE FUNCTION guiAddParamField {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER caption.
    DECLARE PARAMETER lexIn.
    DECLARE PARAMETER key.

    RETURN guiAddNumberField(parentBox, caption, lexIn[key], {
        PARAMETER newValue.
        SET lexIn[key] TO newValue.
    }).
}.

// Checkbox bound to a Boolean lexicon key
DECLARE FUNCTION guiAddParamToggle {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER caption.
    DECLARE PARAMETER lexIn.
    DECLARE PARAMETER key.

    RETURN guiAddToggle(parentBox, caption, lexIn[key], {
        PARAMETER isOn.
        SET lexIn[key] TO isOn.
    }).
}.

// Tab strip, returns lexicon of name to content box
DECLARE FUNCTION guiAddTabs {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER tabNames.

    LOCAL tabRow IS parentBox:ADDHLAYOUT().
    LOCAL content IS parentBox:ADDVLAYOUT().
    LOCAL pages IS LEXICON().
    LOCAL stacks IS LEXICON().  // what SHOWONLY toggles

    FOR tabName IN tabNames {
        LOCAL page IS content:ADDSTACK().
        LOCAL inner IS page:ADDVLAYOUT().
        SET stacks[tabName] TO page.
        SET pages[tabName] TO inner.
        tabRow:ADDRADIOBUTTON(tabName, tabName = tabNames[0]).
    }.

    // Show page matching the click
    SET tabRow:ONRADIOCHANGE TO {
        PARAMETER whichButton.
        content:SHOWONLY(stacks[whichButton:TEXT]).
    }.

    content:SHOWONLY(stacks[tabNames[0]]).
    RETURN pages.
}.

// Text field row, delegate gets the string
DECLARE FUNCTION guiAddTextField {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER caption.
    DECLARE PARAMETER initialText.
    DECLARE PARAMETER onConfirm.

    LOCAL fieldRow IS parentBox:ADDHLAYOUT().
    LOCAL fieldCaption IS fieldRow:ADDLABEL(colorText(caption, guiTheme["captionColor"])).
    SET fieldCaption:STYLE:WIDTH TO guiTheme["captionWidth"].
    SET fieldCaption:STYLE:ALIGN TO "LEFT".

    LOCAL field IS fieldRow:ADDTEXTFIELD(initialText).
    SET field:STYLE:HSTRETCH TO TRUE.
    SET field:ONCONFIRM TO onConfirm.
    RETURN field.
}.

// Number field row, delegate gets the number
DECLARE FUNCTION guiAddNumberField {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER caption.
    DECLARE PARAMETER initialValue.
    DECLARE PARAMETER onConfirm.

    LOCAL fieldRow IS parentBox:ADDHLAYOUT().
    LOCAL fieldCaption IS fieldRow:ADDLABEL(colorText(caption, guiTheme["captionColor"])).
    SET fieldCaption:STYLE:WIDTH TO guiTheme["captionWidth"].
    SET fieldCaption:STYLE:ALIGN TO "LEFT".

    LOCAL field IS fieldRow:ADDTEXTFIELD("" + initialValue).
    SET field:STYLE:HSTRETCH TO TRUE.
    SET field:ONCONFIRM TO {
        PARAMETER newText.
        onConfirm:CALL(newText:TONUMBER(initialValue)).
    }.
    RETURN field.
}.

// Blank space, -1 is flexible
DECLARE FUNCTION guiSpacer {
    DECLARE PARAMETER size IS 5.
    DECLARE PARAMETER parentBox IS guiState["window"].

    RETURN parentBox:ADDSPACING(size).
}.
// --------------------------------------------------------------

// REFRESH LOOP
// Runs every updater, skipped while hidden
DECLARE FUNCTION refreshGui {
    IF NOT guiState["created"] OR NOT guiState["visible"] {
        RETURN.
    }.

    FOR updater IN guiState["updaters"] {
        updater:CALL().
    }.
}.

// Arms timed refresh, trigger installed once
DECLARE FUNCTION armGuiRefresh {
    DECLARE PARAMETER interval IS guiConfig["refreshInterval"].

    SET guiState["refreshInterval"] TO interval.
    SET guiState["nextRefresh"] TO TIME:SECONDS + interval.
    SET guiState["refreshArmed"] TO TRUE.

    IF guiState["refreshInstalled"] {
        RETURN.
    }.
    SET guiState["refreshInstalled"] TO TRUE.

    WHEN guiState["refreshArmed"] AND TIME:SECONDS >= guiState["nextRefresh"] THEN {
        refreshGui().
        SET guiState["nextRefresh"] TO TIME:SECONDS + guiState["refreshInterval"].
        PRESERVE.
    }.
}.

// Stops the refresh trigger
DECLARE FUNCTION disarmGuiRefresh {
    SET guiState["refreshArmed"] TO FALSE.
}.
