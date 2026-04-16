# Pattern: Detect goroutine leaks with goleak or runtime.NumGoroutine

**Domain:** Correctness / Debt

**Mechanism:** Goroutines that block on channels or I/O without a cancellation path grow unbounded over time, exhausting memory and file descriptors. goleak in tests or periodic `runtime.NumGoroutine()` checks surface leaks before production.

**Applies When:** Hypothesis type is Correctness or Debt; goroutine count grows over time under load; long-running service with background workers; test suite uses channels or goroutines.

**Does Not Apply When:** Application is short-lived (CLI, one-shot); goroutine count is stable; leak is already identified and the hypothesis targets the fix.

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
