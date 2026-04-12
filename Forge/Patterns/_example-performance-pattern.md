# Pattern: Profile before vectorizing

**Domain:** Performance

**Mechanism:** Hot-path cost must be proven by a profiler before loop rewrites; otherwise changes optimize the wrong layer.

**Applies When:** Hypothesis type is Performance and a single function or loop dominates CPU in `cProfile` or `py-spy`.

**Does Not Apply When:** I/O or allocation dominates; correctness bugs; micro-optimizations under measurement noise.

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-12
