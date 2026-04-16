# Pattern: Reuse allocations with sync.Pool in Go hot paths

**Domain:** Performance

**Mechanism:** sync.Pool maintains a per-CPU cache of reusable objects, reducing allocator pressure in high-throughput code. Objects retrieved from a Pool may be zeroed and reused rather than garbage-collected and reallocated each request.

**Applies When:** Hypothesis type is Performance; pprof shows high allocation rate of same-typed objects (bytes.Buffer, []byte slices, structs); objects are short-lived and request-scoped.

**Does Not Apply When:** Objects hold state that must not be shared across requests (sessions, DB connections); allocation rate is already low; object size is tiny (< 64 bytes — stack allocation is likely cheaper).

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
