# Pattern: Establish passing tests before any optimization cycle

**Domain:** Universal

**Mechanism:** An optimization that breaks correctness produces a false SCORE improvement (TEST_SCORE collapses). Running tests first ensures any SCORE change during a Performance cycle is real, not a regression masked by a broken harness.

**Applies When:** Before any Performance-type hypothesis; TEST_SCORE is below 10.0; the hypothesis modifies a core algorithm or data structure.

**Does Not Apply When:** TEST_SCORE is already 10.0 and tests are known-good; the hypothesis is Debt-type with no behavior change (pure refactor with identical outputs).

**Confirmation Count:** 0

**Projects:** (applies to all Forge projects)

**Last Updated:** 2026-04-16
