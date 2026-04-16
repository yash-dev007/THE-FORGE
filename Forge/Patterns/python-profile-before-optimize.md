# Pattern: Profile before optimizing Python code

**Domain:** Performance

**Mechanism:** Python's GIL and dynamic dispatch make intuition unreliable. Profiling (cProfile, py-spy) reveals the actual hotspot before any code changes. Optimizing the wrong function wastes a cycle.

**Applies When:** Hypothesis type is Performance; codebase is Python; no prior profiling data exists for the target path.

**Does Not Apply When:** I/O dominates (profiler will show time in syscalls, not Python code); correctness bugs are present (fix those first); target is already identified by prior profiling.

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
