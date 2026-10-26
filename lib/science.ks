// RP-1 procedural avionics experiment helpers.
// Only true Experiment modules are considered science modules.
// Blank underscore events are placeholders and must be ignored.
//
// Toggling uses the module's "start: <name>" / "stop: <name>" ACTIONS, not its
// EVENT captions: KSP only populates an experiment's EVENT text after the
// player has interacted with the part's PAW in-game, but the ACTIONS are
// present and correctly named from the moment the vessel loads. Discovery
// (listAvailableExperiments) reads EVENTS only to test whether a slot is
// equipped (a "_" event means no matching sensor); the experiment's actual
// name/toggle key always comes from its "start: <name>" ACTION instead, since
// the EVENT caption text carries a volatile state suffix (e.g. "pressure
// scan: stopped") that changes as the experiment runs and must never be used
// as an identifier. Telemetry analysis is guaranteed on every avionics core,
// so it is always offered even before its own event has loaded.
//
// The Experiment module exposes no queryable ACTIVE field (confirmed against
// a real logs/partDumpSaved.txt dump - only ACTION/EVENT, no FIELD entries),
// so kOS has no way to ask KSP whether an experiment is currently running.
// Enabled state is therefore tracked locally in experimentEnabledState and
// only changes when toggleExperimentEvent successfully fires an action.
//
// Example:
//   RUNONCEPATH("0:/lib/science.ks").
//   LOCAL experimentList IS listAvailableExperiments().
//   toggleExperimentEvent(telemetryExperimentName).
//   LOCAL state IS refreshExperimentState(experimentList).

GLOBAL telemetryExperimentName IS "telemetry analysis".

// Local mirror of each experiment's enabled state, keyed by lowercase name -
// the only source of truth, since the game exposes no readable state field.
GLOBAL experimentEnabledState IS LEXICON().

DECLARE FUNCTION isValidExperimentEvent {
    DECLARE PARAMETER eventName.

    RETURN NOT (eventName = "" OR eventName = "_" OR eventName:TOLOWER() = "_").
}. 

DECLARE FUNCTION shipHasExperiments {
    FOR part IN SHIP:PARTS {
        FOR idx IN RANGE(0, part:MODULES:LENGTH) {
            IF part:GETMODULEBYINDEX(idx):NAME:TOLOWER() = "experiment" {
                RETURN TRUE.
            }.
        }.
    }.
    RETURN FALSE.
}.

DECLARE FUNCTION listAvailableExperiments {
    LOCAL results IS LIST().
    LOCAL seen IS LEXICON().

    FOR part IN SHIP:PARTS {
        FOR idx IN RANGE(0, part:MODULES:LENGTH) {
            LOCAL moduleRef IS part:GETMODULEBYINDEX(idx).

            IF moduleRef:NAME:TOLOWER() = "experiment" {
                // EVENTS are only used to test whether this slot is equipped
                // (blank "_" = no matching sensor) - their caption text also
                // carries a volatile state suffix ("pressure scan: stopped")
                // that changes as the experiment runs, so it must never be
                // used as the experiment's name/toggle key. The real, stable
                // name comes from the "start: <name>" ACTION instead.
                LOCAL isEquipped IS FALSE.
                FOR currentEvent IN moduleRef:ALLEVENTNAMES {
                    IF isValidExperimentEvent(currentEvent) {
                        SET isEquipped TO TRUE.
                    }.
                }.

                IF isEquipped {
                    FOR actionName IN moduleRef:ALLACTIONNAMES {
                        LOCAL lowerAction IS actionName:TOLOWER().
                        IF lowerAction:STARTSWITH("start:") {
                            LOCAL expKey IS lowerAction:REPLACE("start:", ""):TRIM().
                            IF expKey <> "" AND NOT seen:HASKEY(expKey) {
                                SET seen[expKey] TO TRUE.
                                results:ADD(expKey).
                            }.
                        }.
                    }
                }.
            }.
        }
    }

    IF NOT seen:HASKEY(telemetryExperimentName:TOLOWER()) {
        results:ADD(telemetryExperimentName).
    }.

    RETURN results.
}. 

DECLARE FUNCTION toggleExperimentEvent {
    DECLARE PARAMETER eventName.

    IF NOT isValidExperimentEvent(eventName) {
        RETURN FALSE.
    }.

    LOCAL key IS eventName:TOLOWER().
    LOCAL turningOn IS NOT getExperimentEnabled(eventName).
    LOCAL wantAction IS "stop: " + key.
    IF turningOn {
        SET wantAction TO "start: " + key.
    }.

    FOR part IN SHIP:PARTS {
        FOR idx IN RANGE(0, part:MODULES:LENGTH) {
            LOCAL moduleRef IS part:GETMODULEBYINDEX(idx).

            IF moduleRef:NAME:TOLOWER() = "experiment" {
                FOR actionName IN moduleRef:ALLACTIONNAMES {
                    IF actionName:TOLOWER() = wantAction {
                        moduleRef:DOACTION(actionName, TRUE).
                        SET experimentEnabledState[key] TO turningOn.
                        RETURN TRUE.
                    }.
                }
            }.
        }
    }

    RETURN FALSE.
}. 

DECLARE FUNCTION getExperimentEnabled {
    DECLARE PARAMETER eventName.

    IF NOT isValidExperimentEvent(eventName) {
        RETURN FALSE.
    }.

    LOCAL key IS eventName:TOLOWER().
    IF experimentEnabledState:HASKEY(key) {
        RETURN experimentEnabledState[key].
    }.

    RETURN FALSE. // Not toggled yet this session - experiments start stopped.
}. 

DECLARE FUNCTION refreshExperimentState {
    DECLARE PARAMETER experimentList.

    LOCAL state IS LEXICON().

    FOR eventName IN experimentList {
        SET state[eventName] TO getExperimentEnabled(eventName).
    }

    RETURN state.
}. 

// GUI flow:
//   1) listAvailableExperiments() always offers telemetryExperimentName, plus any
//      other experiment whose EVENT caption has already loaded.
//   2) toggleExperimentEvent(name) fires the module's start:/stop: ACTION, so it
//      works even before that experiment's own EVENT caption has loaded, and
//      records the resulting state in experimentEnabledState.
//   3) once telemetry reads enabled, call listAvailableExperiments() again - the
//      interaction that started it loads the other real experiments' EVENT
//      captions too, so previously-hidden ones now appear in the list.
//   4) refreshExperimentState(list) / getExperimentEnabled(name) just read back
//      experimentEnabledState each updater tick - there is no in-game field to
//      re-query, so this local mirror is the only source of truth.
