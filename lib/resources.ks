// EXPLAINATION
// Resource reads for whole ship or tagged parts, "" = all.
// --------------------------------------------------------------

// RESOURCE READS
// Skipped by whole-tank reads
GLOBAL payloadResourceNames IS LIST().

// Percent from two values
DECLARE FUNCTION getPercent {
    DECLARE PARAMETER currentAmount.
    DECLARE PARAMETER totalAmount.

    IF totalAmount <= 0 {
        RETURN 0.
    }.

    RETURN ROUND((currentAmount / totalAmount) * 100, 1).
}.

// Resource names on ship or tag
DECLARE FUNCTION getResourceNames {
    DECLARE PARAMETER partTag IS "".

    LOCAL names IS LIST().

    IF partTag = "" {
        FOR res IN SHIP:RESOURCES {
            names:ADD(res:NAME).
        }.
        RETURN names.
    }.

    FOR part IN SHIP:PARTSTAGGED(partTag) {
        FOR res IN part:RESOURCES {
            IF NOT names:CONTAINS(res:NAME) {
                names:ADD(res:NAME).
            }.
        }.
    }.

    RETURN names.
}.

// Current amount of a resource
DECLARE FUNCTION getResourceAmount {
    DECLARE PARAMETER resourceName IS "".
    DECLARE PARAMETER partTag IS "".

    LOCAL total IS 0.

    IF partTag = "" {
        FOR res IN SHIP:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip payload
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:AMOUNT.
            }.
        }.
        RETURN total.
    }.

    FOR part IN SHIP:PARTSTAGGED(partTag) {
        FOR res IN part:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip payload
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:AMOUNT.
            }.
        }.
    }.

    RETURN total.
}.

// Capacity of a resource
DECLARE FUNCTION getResourceCapacity {
    DECLARE PARAMETER resourceName IS "".
    DECLARE PARAMETER partTag IS "".

    LOCAL total IS 0.

    IF partTag = "" {
        FOR res IN SHIP:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip payload
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:CAPACITY.
            }.
        }.
        RETURN total.
    }.

    FOR part IN SHIP:PARTSTAGGED(partTag) {
        FOR res IN part:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip payload
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:CAPACITY.
            }.
        }.
    }.

    RETURN total.
}.

// Percent full of a resource
DECLARE FUNCTION getResourcePercent {
    DECLARE PARAMETER resourceName IS "".
    DECLARE PARAMETER partTag IS "".

    RETURN getPercent(getResourceAmount(resourceName, partTag), getResourceCapacity(resourceName, partTag)).
}.

// Amount, capacity and percent per resource
DECLARE FUNCTION getResourceSummary {
    DECLARE PARAMETER partTag IS "".

    LOCAL summary IS LEXICON().

    FOR name IN getResourceNames(partTag) {
        SET summary[name] TO LEXICON(
            "amount", getResourceAmount(name, partTag),
            "capacity", getResourceCapacity(name, partTag),
            "percent", getResourcePercent(name, partTag)
        ).
    }.

    RETURN summary.
}.

// Old name for getResourceAmount
DECLARE FUNCTION sumPartResource {
    DECLARE PARAMETER partTag.
    DECLARE PARAMETER resourceName.

    RETURN getResourceAmount(resourceName, partTag).
}.
// --------------------------------------------------------------
