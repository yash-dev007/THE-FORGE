# Pattern: Avoid interface boxing of small values in hot paths (Go)

**Domain:** Performance

**Mechanism:** Storing a concrete value in an interface causes a heap allocation (boxing) unless the value fits in a pointer. In tight loops or high-frequency code paths, this creates GC pressure. Using concrete types or generics (Go 1.18+) in hot paths eliminates boxing.

**Applies When:** Hypothesis type is Performance; Go profiler (pprof) shows allocations in hot path; interface{} or any is used frequently; the interface has a small number of implementations.

**Does Not Apply When:** Hot path is I/O bound (allocation cost is irrelevant); interface polymorphism is required and concrete type is large; Go version < 1.18 (generics unavailable).

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
