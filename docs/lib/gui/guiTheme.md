# guiTheme.ks

Path: `0:/lib/gui/guiTheme.ks`

## Purpose
Visual theme for the GUI system. Provides colours, font sizes, and rich-text
string helpers. Pure formatting - no widgets are created here.

## Imports
- None (consumed by the other `lib/gui/` modules).

## Globals declared
- `guiTheme` - lexicon of hex colours (`captionColor`, `valueColor`, `nominalColor`, `alertColor`, `criticalColor`, `accentColor`, `mutedColor`) and sizes (`titleSize`, `headingSize`, `captionWidth`). The default palette is matched to the COSMIC FLEET logo: black field, scarlet `accentColor` (headings/title), silver `captionColor`, with the green/amber/red status trio kept for signalling. Edit once to restyle the whole GUI.

## Functions
- `colorText(text, colorHex)` - wrap text in a `<color>` rich-text tag.
- `boldText(text)` - wrap text in a `<b>` tag.
- `sizeText(text, fontSize)` - wrap text in a `<size>` tag.
- `titleText(text)` - pre-styled window title string (bold + title size).
- `headingText(text)` - pre-styled accent-coloured section heading string.
- `statusColor(statusKey)` - map a log-style key (CRITICAL/WARNING/NOMINAL/...) to a theme hex colour.
- `statusText(text, statusKey)` - colour a value string by status key.
- `barText(pct, cells)` - build a fixed-width text progress bar string, e.g. `[####------]` (kOS has no native bar/dial widget). `pct` is 0..100 (clamped); `cells` is the width in characters (default 20). Returns a plain string - wrap in `statusText(...)` to colour it and feed it to a label with `setWidgetText`. Edit the `#`/`-` glyphs in the function for a different fill (e.g. block characters).

## Notes
Rich-text tags follow the kOS Label spec (Unity markup): `<b>`, `<i>`,
`<size=nnn>`, `<color=name>`/`<color=#rrggbbaa>`. Edit `guiTheme` once to restyle
the whole GUI. Status keys mirror the console `[TAG]` scheme so the window and
log stay visually consistent.
