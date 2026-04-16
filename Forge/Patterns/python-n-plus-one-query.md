# Pattern: N+1 query elimination in Python ORMs

**Domain:** Performance

**Mechanism:** Looping over a queryset and accessing a related object triggers one SQL query per row. Eager loading (select_related / prefetch_related in Django; joinedload in SQLAlchemy) batches into 1–2 queries regardless of row count.

**Applies When:** PERF_SCORE is low; database access is in a loop; ORM is Django or SQLAlchemy; profiler or query logger shows repeated similar queries.

**Does Not Apply When:** Dataset is trivially small (<10 rows); the loop accesses different tables per row making batching impossible; query is already optimized with raw SQL.

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
