# logging.ks

Path: `0:/lib/logging.ks`

## Purpose
Project logger. Writes timestamped, tagged lines to the console and/or a log file under `archive:/logs/`. Optionally plays an alert sound based on the message tag. Used by every other library and ship script.

## Globals declared
- `logConfig` - lexicon: `timestamp`, `timeStyle` (`"MS"`, `"HMS"`, `"DHMS"`), `writeFile`, `logFile`, `startTime`.

## Functions
- `pad2(number)` - pads a number to two digits as a string.
- `formatTime(totalSeconds, style)` - formats seconds as `MM:SS`, `HH:MM:SS`, or `D:HH:MM:SS`.
- `getLogTime()` - seconds since `logConfig["startTime"]`.
- `buildLogLine(message, messageType, showTime)` - returns the formatted log line, uppercased.
- `writeLogFile(line)` - appends to the configured log file if `writeFile` is on.
- `playLogSound(messageType)` - maps tag to alert sound (`critical`, `warning`, `alert`).
- `logMessage(message, messageType, consoleTimestamp, playSound, outputToConsole)` - main entry point. Writes to console and/or file, optionally plays a sound.
- `setLogToShipTime(timeStyle, outputToConsole)` - reset clock to ship-relative time.
- `setLogToLaunchTime(timeStyle, outputToConsole)` - reset clock to launch-relative time, called at clamp-held ignition.
- `logBreaker(title)` - writes a separator block to the log file. Used at session and mission boundaries.
- `skipLine(lines)` - prints blank lines to the console for readability.

## Notes
Per-ship logs live at `archive:/logs/<ShipName>_flightlog.txt`. The path is set inside each `programs/<family>.ks`.
