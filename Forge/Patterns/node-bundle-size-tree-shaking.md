# Pattern: Reduce bundle size via tree-shaking and code splitting

**Domain:** Performance

**Mechanism:** Named exports + ESM syntax enables bundlers to eliminate unused code. Default imports from large libraries (e.g. `import _ from 'lodash'`) pull in the entire library. Switching to named imports or per-function packages allows tree-shaking.

**Applies When:** Hypothesis type is Performance; frontend application; PERF_SCORE is low due to bundle load time; bundle analysis shows unused library code.

**Does Not Apply When:** Application is server-side only; bundle is already split aggressively; the library doesn't support ESM tree-shaking (check package `sideEffects` field).

**Confirmation Count:** 0

**Projects:** (list repos where observed)

**Last Updated:** 2026-04-16
