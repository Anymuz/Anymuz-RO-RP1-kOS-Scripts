// RESOURCES
// * Unified resource reads for the whole ship or a tagged subset of parts.
// * partTag "" (default) = whole ship; resourceName "" (default) = every resource in scope.
// --------------------------------------------------------------

// Resources named here are skipped by aggregate (resourceName "") reads - e.g. a non-consumed
// payload sharing a tank with propellant would otherwise skew that tank's fill percentage.
// A resource requested by its own name is never affected by this list.
GLOBAL payloadResourceNames IS LIST().

// Pure percentage from two magnitudes; carries no resource semantics.
DECLARE FUNCTION getPercent {
    DECLARE PARAMETER currentAmount.
    DECLARE PARAMETER totalAmount.

    IF totalAmount <= 0 {
        RETURN 0.
    }.

    RETURN ROUND((currentAmount / totalAmount) * 100, 1).
}.

// Distinct resource names in scope.
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

// Current amount in scope; empty resourceName sums every resource in scope (skipping payloadResourceNames).
DECLARE FUNCTION getResourceAmount {
    DECLARE PARAMETER resourceName IS "".
    DECLARE PARAMETER partTag IS "".

    LOCAL total IS 0.

    IF partTag = "" {
        FOR res IN SHIP:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip: non-consumed payload, would skew a whole-ship aggregate.
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:AMOUNT.
            }.
        }.
        RETURN total.
    }.

    FOR part IN SHIP:PARTSTAGGED(partTag) {
        FOR res IN part:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip: non-consumed payload, would skew a tagged-tank aggregate.
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:AMOUNT.
            }.
        }.
    }.

    RETURN total.
}.

// Capacity in scope; empty resourceName sums every resource in scope (skipping payloadResourceNames).
DECLARE FUNCTION getResourceCapacity {
    DECLARE PARAMETER resourceName IS "".
    DECLARE PARAMETER partTag IS "".

    LOCAL total IS 0.

    IF partTag = "" {
        FOR res IN SHIP:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip: non-consumed payload, would skew a whole-ship aggregate.
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:CAPACITY.
            }.
        }.
        RETURN total.
    }.

    FOR part IN SHIP:PARTSTAGGED(partTag) {
        FOR res IN part:RESOURCES {
            IF resourceName = "" AND payloadResourceNames:CONTAINS(res:NAME) {
                // Skip: non-consumed payload, would skew a tagged-tank aggregate.
            } ELSE IF resourceName = "" OR res:NAME = resourceName {
                SET total TO total + res:CAPACITY.
            }.
        }.
    }.

    RETURN total.
}.

// Fill percentage in scope; empty resourceName gives a whole-tank fill across all resources.
DECLARE FUNCTION getResourcePercent {
    DECLARE PARAMETER resourceName IS "".
    DECLARE PARAMETER partTag IS "".

    RETURN getPercent(getResourceAmount(resourceName, partTag), getResourceCapacity(resourceName, partTag)).
}.

// Snapshot of every resource in scope as name -> LEXICON(amount, capacity, percent).
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

// Amount of one resource across tagged parts; retained for existing callers.
DECLARE FUNCTION sumPartResource {
    DECLARE PARAMETER partTag.
    DECLARE PARAMETER resourceName.

    RETURN getResourceAmount(resourceName, partTag).
}.
