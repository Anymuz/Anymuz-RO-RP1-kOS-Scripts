// Raw part/module/action/event/field dump with explicit science/sensor probes.
// Uses GETMODULEBYINDEX because duplicate module names like Experiment are common in RP-1/Kerbalism.
// Run from the kOS terminal: RUNPATH("0:/boot/partDump.ks").

LOCAL outFile IS "0:/logs/partDump.txt".

IF EXISTS(outFile) {
    DELETEPATH(outFile).
}.

DECLARE FUNCTION dumpLine {
    DECLARE PARAMETER text.
    LOG text TO outFile.
    PRINT text.
}.

DECLARE FUNCTION dumpFile {
    DECLARE PARAMETER text.
    LOG text TO outFile.
}.

DECLARE FUNCTION dumpModuleDetails {
    DECLARE PARAMETER partRef.
    DECLARE PARAMETER moduleIndex.
    DECLARE PARAMETER moduleName.

    LOCAL partModule IS partRef:GETMODULEBYINDEX(moduleIndex).
    dumpFile("  MODULE: " + moduleName + " [index " + moduleIndex + "]").

    FOR a IN partModule:ALLACTIONNAMES {
        dumpFile("    ACTION: " + a).
    }.

    FOR e IN partModule:ALLEVENTNAMES {
        dumpFile("    EVENT : " + e).
    }.

    FOR f IN partModule:ALLFIELDS {
        dumpFile("    FIELD : " + f).
    }.

    IF moduleName = "ModuleScienceExperiment" OR moduleName:CONTAINS("ScienceExperiment") {
        dumpFile("    SCIENCE EXPERIMENT MODULE").
        IF partModule:HASFIELD("HASDATA") {
            dumpFile("      HASDATA: " + partModule:GETFIELD("HASDATA")).
        }.
        IF partModule:HASFIELD("DEPLOYED") {
            dumpFile("      DEPLOYED: " + partModule:GETFIELD("DEPLOYED")).
        }.
        IF partModule:HASFIELD("INOPERABLE") {
            dumpFile("      INOPERABLE: " + partModule:GETFIELD("INOPERABLE")).
        }.
        IF partModule:HASFIELD("RERUNNABLE") {
            dumpFile("      RERUNNABLE: " + partModule:GETFIELD("RERUNNABLE")).
        }.
        IF partModule:HASFIELD("DATA") {
            LOCAL dataList IS partModule:GETFIELD("DATA").
            FOR dataItem IN dataList {
                dumpFile("      DATA: TITLE=" + dataItem:TITLE + " SCIENCEVALUE=" + dataItem:SCIENCEVALUE + " TRANSMITVALUE=" + dataItem:TRANSMITVALUE + " DATAAMOUNT=" + dataItem:DATAAMOUNT).
            }.
        }.
    }.

    IF moduleName = "ModuleScienceContainer" OR moduleName:CONTAINS("ScienceContainer") {
        dumpFile("    SCIENCE CONTAINER MODULE").
        IF partModule:HASFIELD("HASDATA") {
            dumpFile("      HASDATA: " + partModule:GETFIELD("HASDATA")).
        }.
        IF partModule:HASFIELD("DATA") {
            LOCAL dataList IS partModule:GETFIELD("DATA").
            FOR dataItem IN dataList {
                dumpFile("      DATA: TITLE=" + dataItem:TITLE + " SCIENCEVALUE=" + dataItem:SCIENCEVALUE + " TRANSMITVALUE=" + dataItem:TRANSMITVALUE + " DATAAMOUNT=" + dataItem:DATAAMOUNT).
            }.
        }.
    }

    IF moduleName = "Sensor" OR moduleName:CONTAINS("Sensor") OR moduleName = "ModuleEnviroSensor" OR moduleName:CONTAINS("Enviro") {
        dumpFile("    SENSOR MODULE: " + moduleName).
        IF partModule:HASFIELD("TYPE") {
            dumpFile("      TYPE: " + partModule:GETFIELD("TYPE")).
        }.
        IF partModule:HASFIELD("DISPLAY") {
            dumpFile("      DISPLAY: " + partModule:GETFIELD("DISPLAY")).
        }.
        IF partModule:HASFIELD("ACTIVE") {
            dumpFile("      ACTIVE: " + partModule:GETFIELD("ACTIVE")).
        }.
        IF partModule:HASFIELD("POWERCONSUMPTION") {
            dumpFile("      POWERCONSUMPTION: " + partModule:GETFIELD("POWERCONSUMPTION")).
        }.
    }

    IF moduleName = "Configure" OR moduleName = "Experiment" OR moduleName:CONTAINS("Configure") OR moduleName:CONTAINS("Experiment") {
        dumpFile("    TARGETED MODULE PROBE: " + moduleName).
        LOCAL probeNames IS LIST(
            "pressure",
            "temperature",
            "barometer",
            "thermometer",
            "pressure scan",
            "temperature scan",
            "science",
            "telemetry",
            "telemetry analysis",
            "experiment",
            "state",
            "status",
            "data",
            "info",
            "condition",
            "active",
            "enabled",
            "isActive",
            "waiting",
            "value",
            "name",
            "type",
            "result",
            "configure",
            "last",
            "sensor",
            "sensor type",
            "sensorType",
            "experiment type",
            "experimentType",
            "moduleName",
            "module name"
        ).
        FOR candidate IN probeNames {
            IF partModule:HASFIELD(candidate) {
                dumpFile("      HASFIELD: " + candidate + " = " + partModule:GETFIELD(candidate)).
            }.
        }.
    }.
}.

dumpLine("PART DUMP  ship: " + SHIP:NAME).
dumpLine("Total parts: " + SHIP:PARTS:LENGTH).
dumpLine("Duplicate-safe module scan: GETMODULEBYINDEX used for repeated module names like Experiment.").
dumpLine("AG1/AG2/AG3 are vessel-level bindings; KOS exposes the parts in the group, not a direct group-to-action list.").
dumpLine("Full detail -> " + outFile).
dumpFile("==================================================================").

dumpFile("LIST SENSORS").
LIST SENSORS IN sensorList.
IF sensorList:LENGTH = 0 {
    dumpFile("  (no sensors found)").
} ELSE {
    FOR sensorRef IN sensorList {
        dumpFile("  SENSOR: TYPE=" + sensorRef:TYPE + " ACTIVE=" + sensorRef:ACTIVE + " DISPLAY=" + sensorRef:DISPLAY + " POWER=" + sensorRef:POWERCONSUMPTION).
    }
}.

dumpFile("==================================================================").

dumpFile("SCIENCE MODULES ON THIS VESSEL").
FOR part IN SHIP:PARTS {
    LOCAL moduleNames IS part:MODULES.
    FOR idx IN RANGE(0, moduleNames:LENGTH) {
        LOCAL moduleName IS moduleNames[idx].
        LOCAL moduleIsScienceLike IS FALSE.
        IF moduleName = "Configure" OR moduleName = "Experiment" OR moduleName = "Sensor" OR
           moduleName:CONTAINS("Science") OR moduleName:CONTAINS("Enviro") OR moduleName:CONTAINS("Sensor") {
            SET moduleIsScienceLike TO TRUE.
        }.
        IF moduleIsScienceLike {
            dumpFile("PART: " + part:NAME + " TAG: " + part:TAG + " MODULE: " + moduleName + " [idx " + idx + "]").
            dumpModuleDetails(part, idx, moduleName).
            dumpFile("").
        }
    }
}.

dumpFile("==================================================================").

dumpFile("ACTION GROUP MEMBERSHIP SUMMARY").
FOR groupName IN LIST("AG1", "AG2", "AG3") {
    LOCAL groupParts IS SHIP:PARTSINGROUP(groupName).
    dumpFile("GROUP: " + groupName + "  part count: " + groupParts:LENGTH).
    IF groupParts:LENGTH > 0 {
        FOR p IN groupParts {
            LOCAL pTag IS p:TAG.
            IF pTag = "" {
                SET pTag TO "(no tag)".
            }.
            dumpFile("  PART: " + p:NAME + " | TAG: " + pTag + " | TITLE: " + p:TITLE).
            LOCAL moduleNames IS p:MODULES.
            FOR idx IN RANGE(0, moduleNames:LENGTH) {
                dumpModuleDetails(p, idx, moduleNames[idx]).
            }
        }
    }
    dumpFile("").
}.

dumpFile("==================================================================").
dumpFile("FULL PART LIST").

FOR part IN SHIP:PARTS {
    LOCAL tagText IS part:TAG.
    IF tagText = "" {
        SET tagText TO "(no tag)".
    }.

    dumpFile("").
    dumpFile("PART : " + part:TITLE).
    dumpFile("  name  : " + part:NAME).
    dumpFile("  tag   : " + tagText).
    dumpFile("  stage : " + part:STAGE).

    LOCAL moduleNames IS part:MODULES.
    IF moduleNames:LENGTH = 0 {
        dumpFile("  (no modules)").
    } ELSE {
        LOCAL experiments IS LIST().
        LOCAL groupActionNames IS LIST().

        FOR idx IN RANGE(0, moduleNames:LENGTH) {
            LOCAL moduleName IS moduleNames[idx].
            LOCAL partModule IS part:GETMODULEBYINDEX(idx).
            LOCAL moduleExperimentActions IS LIST().

            FOR e IN partModule:ALLEVENTNAMES {
                dumpFile("    EVENT : " + e).
            }.

            FOR a IN partModule:ALLACTIONNAMES {
                dumpFile("    ACTION: " + a).
                IF NOT groupActionNames:CONTAINS(a) {
                    groupActionNames:ADD(a).
                }.
                IF a:STARTSWITH("start:") {
                    LOCAL title IS a:REPLACE("start:", ""):TRIM().
                    IF title <> "" {
                        moduleExperimentActions:ADD(title).
                        IF NOT experiments:CONTAINS(title) {
                            experiments:ADD(title).
                        }.
                    }.
                }.
            }.

            FOR f IN partModule:ALLFIELDS {
                dumpFile("    FIELD : " + f).
            }.

            IF moduleName = "Configure" OR moduleName = "Experiment" OR moduleName = "Sensor" OR
               moduleName:CONTAINS("Configure") OR moduleName:CONTAINS("Experiment") OR moduleName:CONTAINS("Sensor") {
                dumpFile("    TARGETED MODULE PROBE: " + moduleName).
                LOCAL probeNames IS LIST(
                    "pressure",
                    "temperature",
                    "barometer",
                    "thermometer",
                    "pressure scan",
                    "temperature scan",
                    "science",
                    "telemetry",
                    "telemetry analysis",
                    "experiment",
                    "state",
                    "status",
                    "data",
                    "info",
                    "condition",
                    "active",
                    "enabled",
                    "isActive",
                    "waiting",
                    "value",
                    "name",
                    "type",
                    "result",
                    "configure",
                    "last",
                    "sensor",
                    "sensor type",
                    "sensorType",
                    "experiment type",
                    "experimentType",
                    "moduleName",
                    "module name"
                ).
                FOR candidate IN probeNames {
                    IF partModule:HASFIELD(candidate) {
                        dumpFile("      HASFIELD: " + candidate + " = " + partModule:GETFIELD(candidate)).
                    }.
                }.
            }

            IF moduleName = "Sensor" OR moduleName:CONTAINS("Sensor") {
                dumpFile("    SENSOR MODULE: " + moduleName).
                FOR sField IN partModule:ALLFIELDS {
                    dumpFile("      SENSOR FIELD : " + sField).
                }
                FOR sEvent IN partModule:ALLEVENTNAMES {
                    dumpFile("      SENSOR EVENT : " + sEvent).
                }
                FOR sAction IN partModule:ALLACTIONNAMES {
                    dumpFile("      SENSOR ACTION: " + sAction).
                }
            }

            IF moduleExperimentActions:LENGTH > 0 {
                dumpFile("    START ACTIONS: " + moduleExperimentActions:JOIN(", ")).
            }
        }

        IF groupActionNames:LENGTH > 0 {
            dumpFile("  ACTION GROUP ACTIONS: " + groupActionNames:JOIN(", ")).
        }

        IF experiments:LENGTH > 0 {
            dumpFile("  EXPERIMENTS: " + experiments:JOIN(", ")).
        }
    }

    IF part:TAG <> "" {
        dumpLine("[" + part:TAG + "] " + part:NAME).
    }
}.

dumpFile("==================================================================").
dumpFile("BRUTE FORCE ACTION / EVENT TEST").
FOR part IN SHIP:PARTS {
    LOCAL moduleNames IS part:MODULES.
    FOR idx IN RANGE(0, moduleNames:LENGTH) {
        LOCAL moduleName IS moduleNames[idx].
        IF moduleName = "Configure" OR moduleName = "Experiment" OR moduleName = "Sensor" OR
           moduleName:CONTAINS("Science") OR moduleName:CONTAINS("Enviro") OR moduleName:CONTAINS("Sensor") {
            LOCAL moduleRef IS part:GETMODULEBYINDEX(idx).
            dumpFile("PART: " + part:NAME + " MODULE: " + moduleName + " [idx " + idx + "]").

            FOR actionName IN moduleRef:ALLACTIONNAMES {
                IF actionName:CONTAINS("telemetry") OR actionName:CONTAINS("pressure") OR
                   actionName:CONTAINS("temperature") OR actionName:CONTAINS("sensor") OR
                   actionName:CONTAINS("science") OR actionName:CONTAINS("start") OR
                   actionName:CONTAINS("stop") {
                    dumpFile("  CALLING ACTION: " + actionName).
                    moduleRef:DOACTION(actionName, TRUE).
                }.
            }

            FOR eventName IN moduleRef:ALLEVENTNAMES {
                IF eventName:CONTAINS("telemetry") OR eventName:CONTAINS("pressure") OR
                   eventName:CONTAINS("temperature") OR eventName:CONTAINS("sensor") OR
                   eventName:CONTAINS("science") OR eventName:CONTAINS("start") OR
                   eventName:CONTAINS("stop") {
                    dumpFile("  CALLING EVENT: " + eventName).
                    moduleRef:DOEVENT(eventName).
                }.
            }
        }
    }
}

dumpFile("==================================================================").
dumpLine("Dump complete. Open " + outFile + " for the full action/event list.").
