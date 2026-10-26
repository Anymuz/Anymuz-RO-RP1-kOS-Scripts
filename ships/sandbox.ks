// ==============================================================
// GUI SANDBOX SHIP - a place to practise building panels
// ==============================================================
// * This is NOT a real flight script. It flies nothing, arms nothing, and
//   touches no rocket parts - it just opens the mission-control window so you can
//   experiment with GUI panels safely before wiring them into a real ship.
//
// * HOW TO RUN IT (two ways):
//     1. Name any craft "Sandbox" and launch normally - the boot loader will run
//        this file automatically (see system/loadShip.ks).
//     2. Or, on any craft already booted, type in the kOS terminal:
//            RUNPATH("0:/ships/sandbox.ks").
//
// * WHERE TO EXPERIMENT: scroll to the "EDIT BELOW" banner. Change the panel,
//   save, and re-run this file to see your changes. Everything above that banner
//   is just setup you can ignore.
//
// * Docs: lib/gui/README.md (concepts + recipes) and lib/gui/REFERENCE.md (full API).
// --------------------------------------------------------------

// SETUP (safe to ignore)
// Load the dependencies the GUI needs. RUNONCEPATH is idempotent, so if the normal
// boot already loaded these, these lines do nothing. This makes the sandbox work
// whether it is booted normally or run by hand from the terminal.
RUNONCEPATH("0:/lib/logging.ks").
RUNONCEPATH("0:/lib/utils.ks").
RUNONCEPATH("0:/lib/resources.ks").
RUNONCEPATH("0:/lib/parts.ks").
RUNONCEPATH("0:/lib/audio.ks").
setupAudio(). // Initialise the audio driver so the test-tone button works standalone.

// A couple of globals the stock panels expect. The normal boot sets these too;
// re-declaring a GLOBAL just reassigns it, so this is harmless either way and lets
// the sandbox run standalone without the flight data ever being missing.
GLOBAL shipName IS SHIP:NAME.
GLOBAL shipResources IS getResourceSummary().
GLOBAL flightData IS LEXICON().
SET flightData["phase"] TO "sandbox".
SET flightData["maxVelocity"] TO 0.
SET flightData["maxVelocityAlt"] TO 0.
SET flightData["apogeeAlt"] TO 0.
SET flightData["apogeeVelocity"] TO 0.
SET flightData["maxApoapsis"] TO 0.
SET flightData["maxApoapsisAlt"] TO 0.
SET flightData["descentCaptured"] TO FALSE.
SET flightData["launchGeo"] TO SHIP:GEOPOSITION.

RUNONCEPATH("0:/lib/gui/gui.ks"). // Load the shared GUI toolkit (panels loaded per-need below).
RUNONCEPATH("0:/lib/gui/panels/telemetryPanel.ks"). // Stock panels this sandbox lists.
RUNONCEPATH("0:/lib/gui/panels/flightDataPanel.ks").
logMessage("GUI sandbox loaded.", "system", TRUE, FALSE, TRUE).
// --------------------------------------------------------------


// ==============================================================
// ===================  EDIT BELOW - YOUR PANEL  ================
// ==============================================================
// This is a normal panel builder, exactly like the ones in lib/gui/panels/. It is
// defined right here in the sandbox so you can edit and re-run it instantly, with
// no need to register a file. When a panel is finished, copy this function into
// its own lib/gui/panels/<name>.ks file (see lib/gui/README.md).
//
// Try things: change the rows, add buttons, uncomment the examples. Every helper
// used here is documented in lib/gui/README.md.

DECLARE FUNCTION buildSandboxPanel {
    DECLARE PARAMETER parentBox IS guiState["window"]. // Where to build. The dashboard passes the tab's box.

    LOCAL panel IS parentBox:ADDVBOX(). // Your own bordered section inside the tab.
    guiAddHeading(panel, "SANDBOX").

    // --- A live value -------------------------------------------------------
    // A status row needs TWO things: the row (which you name with an id), and an
    // updater that finds it by that id every cycle and rewrites its text.
    guiAddStatusRow(panel, "Altitude", "sbxAlt").          // id "sbxAlt" - must be unique
    guiAddStatusRow(panel, "Vertical speed", "sbxVspd").
    registerUpdater({
        setWidgetText("sbxAlt", ROUND(SHIP:ALTITUDE) + " m").
        setWidgetText("sbxVspd", ROUND(SHIP:VERTICALSPEED, 1) + " m/s").
    }).

    // --- A colour-coded value ----------------------------------------------
    // statusText() colours the text by a status word: NOMINAL green, WARNING
    // amber, CRITICAL red. Here we colour the throttle just to show it off.
    guiAddStatusRow(panel, "Throttle", "sbxThr").
    registerUpdater({
        LOCAL pct IS ROUND(THROTTLE * 100).
        LOCAL key IS "NOMINAL".
        IF pct > 80 { SET key TO "WARNING". }.
        IF pct >= 100 { SET key TO "CRITICAL". }.
        setWidgetText("sbxThr", statusText(pct + " %", key)).
    }).

    // --- A plain button -----------------------------------------------------
    // The last argument is the function that runs on click. Keep it instant.
    guiAddButton(panel, "Toggle Lights", { TOGGLE LIGHTS. }).

    // --- A guarded button ---------------------------------------------------
    // For anything you would not want a stray click to do: an ARM box appears
    // next to it, and the action only fires when ARM is ticked.
    guiAddArmedAction(panel, "Play Test Tone", { playAlertSound(). }).

    // --- An editable value, right here on this panel ------------------------
    // There is no "PARAMS tab" - a value the pilot can edit belongs on the panel
    // that uses it. guiAddParamField binds a text box to guiParams["sbxCutoff"]
    // (seeded in SHOW IT below); read guiParams["sbxCutoff"] in your code for it.
    guiAddParamField(panel, "My cutoff", guiParams, "sbxCutoff").

    // --- MORE EXAMPLES TO TRY (uncomment one at a time) --------------------
    // A checkbox (its function gets TRUE/FALSE):
    // guiAddToggle(panel, "SAS", SAS, { PARAMETER isOn. SET SAS TO isOn. }).
    //
    // A little breathing room between sections:
    // guiSpacer(6, panel).

    RETURN panel. // Hand the box back to whoever built it.
}.

// ==============================================================
// ===================  EDIT ABOVE - YOUR PANEL  ================
// ==============================================================


// SHOW IT
// Seed the value the panel's "My cutoff" field edits, before the dashboard builds,
// so the field shows a sensible starting number. (No PARAMS tab - the field lives
// on the panel above.)
SET guiParams["sbxCutoff"] TO 100.

// --- LOGO / BACKGROUND (experiment here) --------------------------------------
// The logo can sit at the top as a fixed image, or fill the window as a
// background. Change these, then re-run this file to see the effect.
SET guiConfig["logo"] TO "docs/images/flag". // COSMIC FLEET logo (archive-relative PNG, no "0:/", no ".png").

// Header mode: a fixed-size image at the top. The logo is ~1.64:1, so keep width
// and height in that ratio or it looks stretched:
SET guiConfig["logoMode"] TO "header".       // "header" / "background" / "off".
SET guiConfig["logoAlign"] TO "CENTER".      // "LEFT", "CENTER" or "RIGHT".
SET guiConfig["logoWidth"] TO 360.           // Logo width in pixels.
SET guiConfig["logoHeight"] TO 220.          // Logo height in pixels (360 / 1.64).

// Background mode: stretch the logo behind the whole window. Use the pre-dimmed
// backdrop (docs/images/backdrop) so the white readouts stay legible. Uncomment
// to try it instead of the header logo:
// SET guiConfig["logoMode"] TO "background".
// SET guiConfig["background"] TO "docs/images/backdrop". // Darkened logo; leave "" to reuse the bright logo.
// ------------------------------------------------------------------------------

// Build a tiny two-tab dashboard: your panel, plus the stock FLIGHT tab next to it
// so you can compare yours against a "real" one. Add more guiAddTab lines to
// experiment with more panels.
guiResetLayout().
guiAddTab("SANDBOX", LIST(buildSandboxPanel@)).
guiAddTab("FLIGHT",  LIST(buildTelemetryPanel@, buildFlightDataPanel@)).

startDashboard("GUI SANDBOX"). // Build, show, and start the refresh timer.
// --------------------------------------------------------------

// HOLD PROGRAM
// Keeps the script alive so the window stays up and keeps refreshing. Press
// Ctrl+C in the terminal to stop, then edit this file and run it again.
WAIT UNTIL FALSE.
// --------------------------------------------------------------
