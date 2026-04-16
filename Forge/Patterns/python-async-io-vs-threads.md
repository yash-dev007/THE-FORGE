# Pattern: Prefer asyncio over threads for I/O-bound Python

**Domain:** Performance

**Mechanism:** Python threads carry GIL contention overhead for CPU work but help for I/O. asyncio avoids thread overhead entirely for I/O-bound code by multiplexing on a single thread. For CPU-bound work neither helps — use multiprocessing.

**Applies When:** Hypothesis type is Performance; bottleneck is network calls, file I/O, or database queries; code is currently using `threading.Thread` for I/O concurrency.

**Does Not Apply When:** Workload is CPU-bound (profiler shows >80% CPU); existing codebase is deeply threaded and migration cost is high; third-party libraries are not async-compatible.

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
