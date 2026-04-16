# Pattern: Always establish a numeric baseline before making any change

**Domain:** Universal

**Mechanism:** Without a pre-change baseline, there is no way to determine whether a score change represents improvement, regression, or noise. The baseline must be measured on unchanged code, three times, with the median used. This is the foundational invariant of the Forge loop.

**Applies When:** Every cycle, always. forge-cycle.sh enforces this automatically.

**Does Not Apply When:** Never skip the baseline. If the harness is too slow to run 3 times, fix the harness — do not reduce the run count below 3.

**Confirmation Count:** 0

**Projects:** (applies to all Forge projects)

**Last Updated:** 2026-04-16
