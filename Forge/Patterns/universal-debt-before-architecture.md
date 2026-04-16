# Pattern: Reduce debt before architectural restructuring

**Domain:** Universal

**Mechanism:** Architectural changes on high-debt code spread complexity into the new structure. Paying down targeted debt first (dead code removal, complexity reduction, interface clarification) makes the subsequent architectural change cheaper, safer, and more likely to improve SCORE sustainably.

**Applies When:** DEBT_SCORE < 5.0; an Architecture-type hypothesis is being planned; the target module has known complexity warnings.

**Does Not Apply When:** The Architecture change is forced (security, compliance, breaking API change); debt is isolated to a separate module from the architectural target; exploration budget is exhausted and a pivot is needed.

**Confirmation Count:** 0

**Projects:** (applies to all Forge projects)

**Last Updated:** 2026-04-16
