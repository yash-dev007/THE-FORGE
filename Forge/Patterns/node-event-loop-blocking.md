# Pattern: Detect and fix event loop blocking in Node.js

**Domain:** Performance

**Mechanism:** Synchronous CPU work on the main thread blocks the event loop, causing all concurrent requests to queue. Moving heavy computation to worker_threads or breaking it into async chunks with setImmediate() restores concurrency.

**Applies When:** Hypothesis type is Performance; Node.js server; p99 latency is high under load but single-request latency is fine; profiler shows synchronous CPU time on main thread.

**Does Not Apply When:** Application is a CLI tool (not a server); bottleneck is I/O not CPU; CPU work is < 5ms (blocking cost is negligible).

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
