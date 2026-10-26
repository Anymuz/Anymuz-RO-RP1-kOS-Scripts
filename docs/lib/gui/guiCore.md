# guiCore.ks

Path: `0:/lib/gui/guiCore.ks`

## Purpose
Core GUI framework: window lifecycle, a named-widget registry, a set of update
callbacks, and a timed refresh trigger. Also provides widget factory helpers.

## Imports
- `0:/lib/gui/guiTheme.ks` (styling helpers)
- `0:/lib/logging.ks` (`logMessage`, used by callers)

## Globals declared
- `guiConfig` - default geometry/cadence (`x`, `y`, `width`, `refreshInterval`), branding (`logo`, `logoMode` = `"header"`/`"background"`/`"off"`, `logoAlign`, `logoWidth`, `logoHeight`, `background`), `engineTag`, and `manualDestruct` (Boolean, default `TRUE`; the RECOVERY panel shows its SELF DESTRUCT button when set). Set before building a window; `logo`/`background` are Archive PNG paths (`""` disables). `logoMode` `"background"` stretches the image behind the window via `STYLE:BG`.
- `guiParams` - empty lexicon of editable mission tunables. Populate it from the ship script, then bind an editable field to a key with `guiAddParamField`/`guiAddParamToggle` on the panel that manages that system; read `guiParams["key"]` where needed. There is no generic PARAMS panel/tab.
- `guiState` - live handles (`window`, `created`, `visible`, `widgets`, `updaters`, `refreshInstalled`, `refreshArmed`, `nextRefresh`).

## Functions
- `createGuiWindow(title, width)` - dispose any existing window and build a fresh empty one with a centred title.
- `showGui()` - `GUI:SHOW` and mark visible.
- `hideGui()` - `GUI:HIDE` without destroying.
- `disposeGui()` - hide, `DISPOSE`, and clear registered widgets/updaters.
- `registerWidget(name, widget)` - store a widget under a string key.
- `setWidgetText(name, text)` - set a registered widget's `TEXT` (ignores unknown names).
- `registerUpdater(delegate)` - add a delegate to run on every refresh.
- `guiAddHeading(box, text)` - add an accent bold section heading.
- `guiAddImage(box, imagePath, width, height)` - add a custom PNG image (from the Archive) at a fixed pixel size.
- `guiAddStatusRow(box, caption, name, initial)` - add a caption/value row; registers the value label under `name`.
- `guiAddBar(box, caption, valueDelegate, cells, warnBelow, critBelow)` - add a self-updating `caption : [bar] pct%` gauge row in one call. `valueDelegate` is a no-arg delegate returning the current percentage (0..100), polled every refresh (must not `WAIT`). The bar auto-colours NOMINAL/WARNING/CRITICAL as the value falls below `warnBelow` (default 40) / `critBelow` (default 15); `cells` sets the width (default 20). Registers its own updater; uses `barText`/`statusText` from `guiTheme.ks`.
- `guiAddButton(box, text, onClick)` - add a click button wired to a no-arg delegate.
- `guiAddToggle(box, text, on, onToggle)` - add a checkbox wired to a one-Boolean delegate.
- `guiAddArmedAction(box, label, onFire)` - add an ARM checkbox + button; `onFire` (no-arg) runs only when ARM is ticked, then auto-disarms. For consequential actions.
- `guiAddTabs(box, tabNames)` - add a tab strip (radio buttons + stacked pages). Returns a lexicon mapping each name to its content box; build panels into `pages[name]`.
- `guiAddTextField(box, caption, initialText, onConfirm)` - add a captioned text input; `onConfirm` is a delegate(String) fired on Enter/blur.
- `guiAddNumberField(box, caption, initialValue, onConfirm)` - like `guiAddTextField` but parses to a number (falls back to `initialValue`); `onConfirm` is a delegate(number).
- `guiAddParamField(box, caption, lex, key)` - a number field bound to `lex[key]`; typing writes the number back. Loop-safe.
- `guiAddParamToggle(box, caption, lex, key)` - a checkbox bound to a Boolean `lex[key]`.
- `guiSpacer(size, box)` - add blank spacing (pixels; `-1` = flexible).
- `refreshGui()` - run every registered updater once (no-op while hidden).
- `armGuiRefresh(interval)` - install/arm a `WHEN` trigger that refreshes on an interval.
- `disarmGuiRefresh()` - stop the refresh trigger (stays installed but dormant).

## Notes
Labels do not auto-update in kOS; a script must reassign `Label:TEXT`. The
registry + single `WHEN ... PRESERVE` trigger handle this cheaply, matching the
pattern in `lib/tracking.ks`. Buttons use `ONCLICK` (callback technique), which
the kOS docs prefer over polling. `armGuiRefresh` installs the trigger once and
gates it with `guiState["refreshArmed"]` so re-arming never stacks triggers.
