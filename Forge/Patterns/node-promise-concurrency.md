# Pattern: Run independent async operations concurrently with Promise.all

**Domain:** Performance

**Mechanism:** Sequential await calls run operations one-at-a-time. If operations are independent (no data dependency), Promise.all() runs them concurrently, reducing total wall time to the slowest operation rather than the sum.

**Applies When:** Multiple await calls appear sequentially and their results are independent; operations involve I/O (network, DB, file); each operation takes > 10ms.

**Does Not Apply When:** Operations have data dependencies (output of one feeds the next); running too many concurrent DB queries saturates the connection pool; rate-limited external APIs.

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
