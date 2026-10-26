// SHIP RESOURCE HELPERS
// Aggregate resource amounts and capacities, optionally limited to a part tag.
// --------------------------------------------------------------

GLOBAL payloadResourceNames IS LIST(
    "Ore",
    "MetalOre",
    "RareMetals",
    "ExoticMinerals",
    "Uraninite",
    "Hydrates",
    "Silicates",
    "Substrate",
    "Water"
).
GLOBAL shipResources IS LEXICON().

DECLARE FUNCTION refreshShipResources {
    SET shipResources TO LEXICON().
    FOR part IN SHIP:PARTS {
        FOR resource IN part:RESOURCES {
            SET shipResources[resource:NAME] TO TRUE.
        }.
    }.
}.

DECLARE FUNCTION getResourceAmount {
    DECLARE PARAMETER resourceName.
    DECLARE PARAMETER partTag IS "".

    LOCAL total IS 0.
    LOCAL parts IS SHIP:PARTS.
    IF partTag <> "" {
        SET parts TO SHIP:PARTSTAGGED(partTag).
    }.

    FOR part IN parts {
        FOR resource IN part:RESOURCES {
            IF resourceName = "" OR resource:NAME = resourceName {
                SET total TO total + resource:AMOUNT.
            }.
        }.
    }.

    RETURN total.
}.

DECLARE FUNCTION getResourceCapacity {
    DECLARE PARAMETER resourceName.
    DECLARE PARAMETER partTag IS "".

    LOCAL total IS 0.
    LOCAL parts IS SHIP:PARTS.
    IF partTag <> "" {
        SET parts TO SHIP:PARTSTAGGED(partTag).
    }.

    FOR part IN parts {
        FOR resource IN part:RESOURCES {
            IF resourceName = "" OR resource:NAME = resourceName {
                SET total TO total + resource:CAPACITY.
            }.
        }.
    }.

    RETURN total.
}.

DECLARE FUNCTION getResourcePercent {
    DECLARE PARAMETER resourceName.
    DECLARE PARAMETER partTag IS "".

    LOCAL capacity IS getResourceCapacity(resourceName, partTag).
    IF capacity <= 0 {
        RETURN 0.
    }.

    RETURN ROUND(100 * getResourceAmount(resourceName, partTag) / capacity, 1).
}.
