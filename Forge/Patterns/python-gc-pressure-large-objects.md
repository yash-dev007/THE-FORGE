# Pattern: Reduce GC pressure from large short-lived Python objects

**Domain:** Performance

**Mechanism:** Allocating and discarding many large objects (dicts, lists, dataframes) in tight loops stresses Python's garbage collector. Reusing buffers, using __slots__ on hot classes, or switching to numpy arrays can dramatically reduce GC pause time.

**Applies When:** Profiler shows significant time in `gc.collect` or `tp_dealloc`; code creates many intermediate dicts/lists in a loop; memory usage spikes and drops repeatedly.

**Does Not Apply When:** Objects are long-lived and reused; workload is purely I/O bound; GC time is < 5% of total runtime per profiler.

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
