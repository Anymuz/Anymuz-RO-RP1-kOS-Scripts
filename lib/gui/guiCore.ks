// GUI CORE
// Window lifecycle, named-widget registry, timed refresh. See docs/lib/gui/.
// --------------------------------------------------------------

// CONFIGURATION
// Default window geometry and refresh cadence. Override before createGuiWindow().
GLOBAL guiConfig IS LEXICON().
SET guiConfig["x"] TO 350.             // Window X (negative = from right edge).
SET guiConfig["y"] TO 250.             // Window Y (negative = from bottom edge).
SET guiConfig["width"] TO 440.         // Window width in pixels (height auto-sizes).
SET guiConfig["refreshInterval"] TO 0.5. // Seconds between label refreshes.
SET guiConfig["logo"] TO "docs/images/flag".  // Brand image, archive-relative PNG (no "0:/", no ".png"). "" = none.
SET guiConfig["logoMode"] TO "header". // "header" = fixed-size image at the top; "background" = stretched behind the whole window; "off" = hidden.
SET guiConfig["logoAlign"] TO "CENTER". // Header mode only: "LEFT", "CENTER" or "RIGHT".
SET guiConfig["logoWidth"] TO 360.     // Header-mode logo width in pixels (logo is ~1.64:1, so height tracks this).
SET guiConfig["logoHeight"] TO 220.    // Header-mode logo height in pixels.
SET guiConfig["background"] TO "".     // Optional window background image (archive-relative PNG). "" = none, unless logoMode is "background" (then the logo is used).
SET guiConfig["engineTag"] TO "U-1250". // Part tag the engine panel reads (set to your main-engine tag).
SET guiConfig["manualDestruct"] TO TRUE. // Show the RECOVERY SELF DESTRUCT button. A ship/family sets this (default TRUE - assume the pilot can always command a destruct).
// --------------------------------------------------------------

// EDITABLE MISSION PARAMETERS
// A shared bag of tunables. Populate it from your ship script (after loading the
// GUI), then bind an editable field to a key with guiAddParamField on the panel
// that manages that system, and read guiParams["..."] where needed. There is no
// generic PARAMS tab - editable inputs live on their own system's panel.
GLOBAL guiParams IS LEXICON().
// --------------------------------------------------------------

// STATE
// Live handles for the current window. Managed by the functions below.
GLOBAL guiState IS LEXICON().
SET guiState["window"] TO 0.           // The GUI() window, or 0 when none exists.
SET guiState["created"] TO FALSE.      // TRUE once a window has been built.
SET guiState["visible"] TO FALSE.      // TRUE while the window is shown.
SET guiState["widgets"] TO LEXICON().  // Named value widgets to update each refresh.
SET guiState["updaters"] TO LIST().    // Delegates run on every refresh.
SET guiState["refreshInstalled"] TO FALSE. // TRUE once the WHEN trigger exists.
SET guiState["refreshArmed"] TO FALSE. // Gates whether the refresh trigger runs.
SET guiState["nextRefresh"] TO 0.      // TIME:SECONDS of the next scheduled refresh.
// --------------------------------------------------------------

// WINDOW LIFECYCLE
// Build a fresh, empty window. Disposes any existing one first.
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

    // Background image: an explicit one, or the logo itself when logoMode is
    // "background". Stretched behind the whole window via the window's style.
    LOCAL bgImage IS guiConfig["background"].
    IF bgImage = "" AND guiConfig["logoMode"] = "background" {
        SET bgImage TO guiConfig["logo"].
    }.
    IF bgImage <> "" {
        SET guiState["window"]:STYLE:BG TO bgImage.
    }.

    // Header logo: a fixed-size branding image at the top. Skipped when the logo
    // is being used as the background, or when turned off / unset. A fixed-width
    // image can't be centered via ALIGN alone, so flank it with flexible spacers
    // instead - the standard kOS trick for positioning a fixed-size widget.
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

// Show the current window and start counting refreshes as visible.
DECLARE FUNCTION showGui {
    IF guiState["created"] {
        guiState["window"]:SHOW().
        SET guiState["visible"] TO TRUE.
    }.
}.

// Hide the current window without destroying it.
DECLARE FUNCTION hideGui {
    IF guiState["created"] {
        guiState["window"]:HIDE().
        SET guiState["visible"] TO FALSE.
    }.
}.

// Hide and destroy the current window, clearing all registered widgets/updaters.
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
// Store a widget under a name so updaters can address it by string key.
DECLARE FUNCTION registerWidget {
    DECLARE PARAMETER widgetName.
    DECLARE PARAMETER widget.

    SET guiState["widgets"][widgetName] TO widget.
    RETURN widget.
}.

// Set the TEXT of a registered widget. Silently ignores unknown names.
DECLARE FUNCTION setWidgetText {
    DECLARE PARAMETER widgetName.
    DECLARE PARAMETER text.

    IF guiState["widgets"]:HASKEY(widgetName) {
        SET guiState["widgets"][widgetName]:TEXT TO text.
    }.
}.

// Register a delegate (named or anonymous) to be called on every refresh.
DECLARE FUNCTION registerUpdater {
    DECLARE PARAMETER updater.

    guiState["updaters"]:ADD(updater).
}.
// --------------------------------------------------------------

// WIDGET FACTORIES
// Add a section heading label to a box.
DECLARE FUNCTION guiAddHeading {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER text.

    LOCAL headingLabel IS parentBox:ADDLABEL(headingText(text)).
    SET headingLabel:STYLE:HSTRETCH TO TRUE.
    SET headingLabel:STYLE:ALIGN TO "LEFT".
    RETURN headingLabel.
}.

// Add a custom image (a PNG in the Archive/Ships/Script volume). The ".png"
// extension is optional. width/height fix the on-screen size in pixels.
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

// Add a "caption : value" row. The value label is registered under widgetName
// so it can be updated later with setWidgetText(widgetName, ...).
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

// Add a self-updating "caption : [bar] pct%" gauge row in one call. valueDelegate
// is a no-argument delegate returning the current percentage (0..100); it is polled
// every refresh (so it must not WAIT). The bar auto-colours NOMINAL/WARNING/CRITICAL
// as the value falls below warnBelow / critBelow. cells sets the bar width. Returns
// the bar label. Uses barText()/statusText() from guiTheme.ks.
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

// Add a click button wired to a no-argument delegate (callback technique).
DECLARE FUNCTION guiAddButton {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER text.
    DECLARE PARAMETER onClick.

    LOCAL button IS parentBox:ADDBUTTON(text).
    SET button:ONCLICK TO onClick.
    RETURN button.
}.

// Add a checkbox (toggle) wired to a one-Boolean-argument delegate.
DECLARE FUNCTION guiAddToggle {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER text.
    DECLARE PARAMETER initialOn.
    DECLARE PARAMETER onToggle.

    LOCAL toggle IS parentBox:ADDCHECKBOX(text, initialOn).
    SET toggle:ONTOGGLE TO onToggle.
    RETURN toggle.
}.

// Add a guarded action: an ARM checkbox next to a button. The onFire delegate
// (no args) runs only if ARM is ticked, and ARM auto-clears after firing. Use
// this for consequential actions so a stray single click cannot trigger them.
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

// Bind a number field to a lexicon key: shows lex[key], writes the typed number
// back into lex[key] on confirm. Wrapping the binding in this function gives each
// field its own captured key, so it is safe to call in a loop.
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

// Bind a checkbox to a Boolean lexicon key.
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

// Add a tab strip. tabNames is a LIST of strings. Returns a LEXICON mapping each
// name to its content box - build panels into pages[name]. One tab shows at a time.
DECLARE FUNCTION guiAddTabs {
    DECLARE PARAMETER parentBox.
    DECLARE PARAMETER tabNames.

    LOCAL tabRow IS parentBox:ADDHLAYOUT().
    LOCAL content IS parentBox:ADDVLAYOUT().
    LOCAL pages IS LEXICON().   // name -> vertical content box (what the caller builds into)
    LOCAL stacks IS LEXICON().  // name -> the stack box SHOWONLY toggles

    FOR tabName IN tabNames {
        LOCAL page IS content:ADDSTACK().          // stacked boxes share the same space
        LOCAL inner IS page:ADDVLAYOUT().          // force vertical layout inside the tab
        SET stacks[tabName] TO page.
        SET pages[tabName] TO inner.
        tabRow:ADDRADIOBUTTON(tabName, tabName = tabNames[0]). // first tab starts selected
    }.

    // One callback for the whole strip: show the page whose name matches the click.
    SET tabRow:ONRADIOCHANGE TO {
        PARAMETER whichButton.
        content:SHOWONLY(stacks[whichButton:TEXT]).
    }.

    content:SHOWONLY(stacks[tabNames[0]]).
    RETURN pages.
}.

// Add a "caption : [text box]" row. onConfirm is a delegate(String) fired when
// the user presses Enter or leaves the field. Returns the TextField.
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

// Add a numeric input row. Like guiAddTextField but parses the entry to a number
// (falling back to initialValue if the text is not a number). onConfirm is a
// delegate(number). Returns the TextField.
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

// Add blank spacing (pixels; -1 = flexible) to a box for layout breathing room.
DECLARE FUNCTION guiSpacer {
    DECLARE PARAMETER size IS 5.
    DECLARE PARAMETER parentBox IS guiState["window"].

    RETURN parentBox:ADDSPACING(size).
}.
// --------------------------------------------------------------

// REFRESH LOOP
// Run every registered updater once. Skipped while the window is hidden.
DECLARE FUNCTION refreshGui {
    IF NOT guiState["created"] OR NOT guiState["visible"] {
        RETURN.
    }.

    FOR updater IN guiState["updaters"] {
        updater:CALL().
    }.
}.

// Arm a timed WHEN trigger that calls refreshGui() every interval seconds.
// The trigger is installed once; re-arming only updates the interval.
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

// Stop the refresh trigger from running (it stays installed but dormant).
DECLARE FUNCTION disarmGuiRefresh {
    SET guiState["refreshArmed"] TO FALSE.
}.
