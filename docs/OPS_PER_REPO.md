# Operations scoped per repository

THE FORGE v3 metrics and cadences are **not global across projects**. Each adopted git repository owns:

| Artifact / metric | Location |
|-------------------|----------|
| Cycle counter (`## Cycle N`) | That repo’s `PROJECT_LOG.md` |
| Velocity reports (every 5 cycles) | Same `PROJECT_LOG.md` |
| Win rate / stagnation (3 reports ≤40%) | Derived **only** from that log |
| Commits since last Auditor | Tracked in velocity table or a one-line header in that log |
| Active hypothesis | That repo’s `RESEARCH.md` |
| Score baselines | That repo’s `RESEARCH.md` after local `./EVAL.sh` |

**Auditor:** Runs on every **five commits** in **that** repository. Reset the counter in `PROJECT_LOG.md` after an audit completes.

**Pattern Distillation:** Every **ten cycles** in **that** repository, compare the last ten `PROJECT_LOG.md` entries with:

- Global: `Forge/Patterns/`
- Project-local: `Forge/Projects/<ForgeProjectSlug>/` for **this** repo only

**Promotion to global patterns:** Still requires the v3 rule — pattern seen on **two or more distinct projects** before a new `Forge/Patterns/` note.

This separation prevents one product’s failed experiments from polluting another’s budgets or win-rate statistics.
