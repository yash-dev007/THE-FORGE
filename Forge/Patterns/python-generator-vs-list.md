# Pattern: Use generators instead of list comprehensions for large sequences

**Domain:** Performance

**Mechanism:** List comprehensions materialize the entire sequence in memory at once. Generators produce values lazily, keeping memory flat regardless of input size. For pipelines that process items one-by-one, generators reduce peak memory and can improve throughput.

**Applies When:** Hypothesis type is Performance or Debt; processing sequences > 10k items; result is consumed once (not indexed, not reversed, not reused); memory is a concern.

**Does Not Apply When:** Result is accessed multiple times or by index; sequence is small (< 1k items); downstream code requires a list explicitly (e.g., json.dumps, len()).

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
