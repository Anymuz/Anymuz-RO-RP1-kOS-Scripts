# resources.ks

Path: `0:/lib/resources.ks`

## Purpose
Unified resource reads for the whole ship or a tagged subset of parts. Replaces the older per-resource-name helpers (`getShipResource*`, `getTaggedFuelPercent`, `getFuelTankPercent`) with one API that takes an optional part tag and an optional resource name.

## Globals declared
- `payloadResourceNames` - `LIST()` of resource names to treat as non-consumed payload. Aggregate reads (`resourceName IS ""`) skip any resource whose name is in this list; a resource asked for by its own name is never affected. Empty by default - set in a family program where a tank shares space with a payload that shouldn't skew the tank's fill percentage.

## Functions
- `getPercent(currentAmount, totalAmount)` - pure percentage of two magnitudes; no resource semantics.
- `getResourceNames(partTag IS "")` - distinct resource names in scope, including payload names (not filtered - each still needs its own row). Empty `partTag` = whole ship; otherwise every resource found on parts tagged `partTag`.
- `getResourceAmount(resourceName IS "", partTag IS "")` - current amount in scope. Empty `resourceName` sums every resource in scope *except* those listed in `payloadResourceNames` (e.g. a whole tank's total fuel regardless of what it's called, without a non-consumed payload skewing the total).
- `getResourceCapacity(resourceName IS "", partTag IS "")` - capacity in scope, same empty-argument and payload-skip rules as `getResourceAmount`.
- `getResourcePercent(resourceName IS "", partTag IS "")` - fill percentage in scope (`getPercent` over the two calls above).
- `getResourceSummary(partTag IS "")` - snapshot of every resource in scope as `name -> LEXICON(amount, capacity, percent)`, one entry per named resource (payloads included, not aggregated together). Used once at program init to build `shipResources`, and by the RESOURCES panel to enumerate rows.
- `sumPartResource(partTag, resourceName)` - thin delegate to `getResourceAmount(resourceName, partTag)`, kept so existing callers (`booster.ks`, `launch.ks` legacy paths) don't need signature changes.

## Notes
Prefer tag-based, name-agnostic reads (`getResourcePercent("", someTag)`) over passing resource name strings around - it keeps ship scripts working regardless of which propellant/oxidizer/booster-fuel resource a part actually contains. Only pass a `resourceName` when you specifically need one named resource (e.g. `ElectricCharge`) out of a scope that contains several.

If a tank carries a non-consumed payload alongside propellant (e.g. a sounding payload that should always read full), add its resource name to `payloadResourceNames` so `getResourcePercent("", fuelTank)` reflects only the consumable fuel. The payload's own reading is unaffected and still available by name, and still gets its own row in the RESOURCES panel's PAYLOADS section.
