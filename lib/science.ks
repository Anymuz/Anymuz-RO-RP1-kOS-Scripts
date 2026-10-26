// SCIENCE EXPERIMENT HELPERS
// Generic access to stock ModuleScienceExperiment parts.
// --------------------------------------------------------------

GLOBAL telemetryExperimentName IS "Telemetry".

DECLARE FUNCTION listAvailableExperiments {
    LOCAL names IS LIST().
    FOR part IN SHIP:PARTS {
        IF part:HASMODULE("ModuleScienceExperiment") AND NOT names:CONTAINS(part:NAME) {
            names:ADD(part:NAME).
        }.
    }.
    RETURN names.
}.

DECLARE FUNCTION getExperimentEnabled {
    DECLARE PARAMETER experimentName.

    FOR part IN SHIP:PARTS {
        IF part:NAME = experimentName AND part:HASMODULE("ModuleScienceExperiment") {
            LOCAL experiment IS part:GETMODULE("ModuleScienceExperiment").
            IF experiment:ALLFIELDNAMES:CONTAINS("Deployed") {
                RETURN experiment:GETFIELD("Deployed").
            }.
            IF experiment:ALLFIELDNAMES:CONTAINS("IsDeployed") {
                RETURN experiment:GETFIELD("IsDeployed").
            }.
        }.
    }.
    RETURN FALSE.
}.

DECLARE FUNCTION toggleExperimentEvent {
    DECLARE PARAMETER experimentName.

    FOR part IN SHIP:PARTS {
        IF part:NAME = experimentName AND part:HASMODULE("ModuleScienceExperiment") {
            LOCAL experiment IS part:GETMODULE("ModuleScienceExperiment").
            LOCAL eventNames IS LIST().
            IF getExperimentEnabled(experimentName) {
                SET eventNames TO LIST("Reset Experiment", "ResetExperiment", "Retract Experiment", "RetractExperiment").
            } ELSE {
                SET eventNames TO LIST("Deploy Experiment", "DeployExperiment", "Run Experiment", "RunExperiment", "Activate Experiment", "ActivateExperiment").
            }.

            FOR eventName IN eventNames {
                IF experiment:HASEVENT(eventName) {
                    experiment:DOEVENT(eventName).
                    RETURN.
                }.
            }.
        }.
    }.
}.
