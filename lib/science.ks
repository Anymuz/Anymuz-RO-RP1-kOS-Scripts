// EXPLAINATION
// RP-1 avionics experiment helpers, toggled by start:/stop: actions.
// --------------------------------------------------------------

// SCIENCE EXPERIMENTS
GLOBAL telemetryExperimentName IS "telemetry analysis".

// Enabled state kept locally, the game has no readable field
GLOBAL experimentEnabledState IS LEXICON().

// TRUE if event is a real one
DECLARE FUNCTION isValidExperimentEvent {
    DECLARE PARAMETER eventName.

    RETURN NOT (eventName = "" OR eventName = "_" OR eventName:TOLOWER() = "_").
}. 

// TRUE if ship has any experiment
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

// Lists equipped experiments, toggle telemetry first to reveal the rest
DECLARE FUNCTION listAvailableExperiments {
    LOCAL results IS LIST().
    LOCAL seen IS LEXICON().

    FOR part IN SHIP:PARTS {
        FOR idx IN RANGE(0, part:MODULES:LENGTH) {
            LOCAL moduleRef IS part:GETMODULEBYINDEX(idx).

            IF moduleRef:NAME:TOLOWER() = "experiment" {
                // Events only show if slot is equipped, name comes from start: action
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

// Starts or stops an experiment
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

// TRUE if experiment is running
DECLARE FUNCTION getExperimentEnabled {
    DECLARE PARAMETER eventName.

    IF NOT isValidExperimentEvent(eventName) {
        RETURN FALSE.
    }.

    LOCAL key IS eventName:TOLOWER().
    IF experimentEnabledState:HASKEY(key) {
        RETURN experimentEnabledState[key].
    }.

    RETURN FALSE.
}. 

// Enabled state for each experiment in list
DECLARE FUNCTION refreshExperimentState {
    DECLARE PARAMETER experimentList.

    LOCAL state IS LEXICON().

    FOR eventName IN experimentList {
        SET state[eventName] TO getExperimentEnabled(eventName).
    }

    RETURN state.
}. 
// --------------------------------------------------------------
