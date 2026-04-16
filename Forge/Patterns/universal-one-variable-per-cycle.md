# Pattern: Change exactly one variable per cycle

**Domain:** Universal

**Mechanism:** Changing multiple variables simultaneously makes it impossible to attribute score changes to a specific mechanism. One change per cycle maintains causal clarity. When a cycle fails, you know exactly what to revert. When it succeeds, you know exactly what worked.

**Applies When:** Every hypothesis cycle, always. The Forge loop enforces this via RESEARCH.md Target Scope.

**Does Not Apply When:** Architecture-type hypotheses (which explicitly restructure multiple components). Even then, the change should be one architectural decision, not several simultaneous refactors.

**Confirmation Count:** 0

**Projects:** (applies to all Forge projects)

**Last Updated:** 2026-04-16
