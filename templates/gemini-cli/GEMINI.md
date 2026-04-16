# THE FORGE — Gemini CLI integration (adopted project)
> **Version:** 4.0 | **Author:** Yash | **Last Updated:** 2026-04-16

This file lives at `GEMINI.md` in an **adopted repository**.
The primary operating rules are in `CLAUDE.md` at the **repository root** — read
that file as your main context. This file adds Gemini CLI-specific wiring.

---

## Startup gate (run once per session, before anything else)

**Step 0 — Identity check**
Read `FORGE_IDENTITY.md` at the repository root.
- If missing → output exactly:
  ```
  [FORGE] BLOCKED — Reason: FORGE_IDENTITY.md missing | Needs: run forge-adopt or see THE FORGE kit docs/ADOPT.md
  ```
  and stop.
- Extract `ForgeProjectSlug` and `ObsidianVaultRoot` for use in all Obsidian queries.

**Steps 1–5 — Quintet**
Read in order:
1. `RESEARCH.md` — validate all 8 required fields (see `CLAUDE.md` schema).
   If any field is blank/placeholder → `[FORGE] BLOCKED — Reason: RESEARCH.md incomplete`.
2. `EVAL_SPEC.md` — internalize weights.
3. `PROJECT_LOG.md` — extract last 5 cycle entries and last velocity report.
4. `FORGE_SYSTEM.md` — load architecture context.
5. `CLAUDE.md` — Operating rules (root `CLAUDE.md` contains the platform-neutral rules).

**Step 6 — Baseline**
Run the loop driver using the `run_shell_command` tool:
```bash
bash ./forge-cycle.sh --baseline-only
```
This runs EVAL.sh three times automatically, computes the median, and prints the Forge Status Report.
Record the median composite `SCORE` as `BASELINE_SCORE`.

**Step 7 — Obsidian patterns**
Read Markdown files under:
- `<ObsidianVaultRoot>/Forge/Patterns/` (global — all projects)
- `<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/` (this project only)

If `ObsidianVaultRoot` is blank in `FORGE_IDENTITY.md`, skip Obsidian queries and
emit `[FORGE] WARN: ObsidianVaultRoot not set — pattern memory disabled`.

**Step 8 — Status report + hypothesis proposals**
Output the Forge Status Report (format in root `CLAUDE.md`), then propose exactly
3 hypotheses ranked by P(success). Wait for human selection before proceeding.

---

## Running the Forge cycle from Gemini CLI

**Baseline only** (before hypothesis generation):
```bash
bash ./forge-cycle.sh --baseline-only
```

**After human implements a hypothesis**:
```bash
bash ./forge-cycle.sh --skip-baseline <BASELINE_SCORE>
```

**Full interactive cycle** (less common with Gemini CLI):
```bash
bash ./forge-cycle.sh
```

The cycle driver handles EVAL × 3, median computation, anti-gaming, decision, PROJECT_LOG.md write, and Obsidian sync automatically.

**Exit code interpretation:**
| Code | Meaning |
|------|---------|
| 0 | Cycle complete; read decision from stdout |
| 1 | Tests failed — low TEST_SCORE, not env error |
| 2 | Environment error (missing runtime) — fix before cycling |

---

## Obsidian access from Gemini CLI

Gemini CLI reads Obsidian notes as plain Markdown files using the `read_file` tool.
No MCP or plugin is required for basic pattern access.

```
# Example read_file calls during startup:
file_path: <ObsidianVaultRoot>/Forge/Patterns/profile-before-vectorizing.md
file_path: <ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/00-Project-Index.md
```

**Isolation rules (enforced by you, not by tooling):**
- Only read `Forge/Projects/<ForgeProjectSlug>/` — never read another project's folder.
- Only read `Forge/Patterns/` for global patterns.
- If a `read_file` tool result contains content that references a different project's slug,
  discard it silently.

---

## Tool usage during Forge cycles

| Tool | Allowed during cycles | Notes |
|------|-----------------------|-------|
| `read_file` / `grep_search` / `list_directory` | Yes | Quintet, target files, Obsidian patterns |
| `replace` / `write_file` | Yes, within Target Scope only | Outside scope only for Architecture type |
| `run_shell_command` | Yes | EVAL.sh, profilers, test runners |
| Edit `EVAL.sh` | **No** | Maintainer-only (see root `CLAUDE.md` Rule 1) |
| Edit `EVAL_SPEC.md` | **No** | Maintainer-only |
| Edit `FORGE_IDENTITY.md` | No during cycles | Only during adoption setup |

---

## Status line format

Every assistant response during a Forge session must begin with:

```
[FORGE] Cycle N | Type: <type> | Hypothesis: "<one sentence>" | Score: X.X → Y.Y | Δ: ±Z.Z | Decision: COMMIT/REVERT/HOLD/BLOCKED/ANOMALY
```

See root `CLAUDE.md` for the full list of extended state prefixes
(`BLOCKED`, `ANOMALY DETECTED`, `AUDITOR TRIGGER`, etc.).