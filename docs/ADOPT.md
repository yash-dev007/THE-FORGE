# Adopt THE FORGE into any repository

This playbook is **repeatable per project**. The kit lives in THE FORGE repository;
each application repo gets its own Quintet, `EVAL.*`, and Obsidian
`Forge/Projects/<slug>/` folder.

---

## Prerequisites

- **Bash** (Git Bash, WSL, or macOS/Linux) to run `EVAL.sh` starters.
- **Obsidian** (optional) — one vault for all projects. See [OBSIDIAN_SETUP.md](OBSIDIAN_SETUP.md).
- **Cursor** or **Claude Code** (or both) — see agent integration steps below.

Per-repo cadences (Auditor, cycles, stagnation) are documented in [OPS_PER_REPO.md](OPS_PER_REPO.md).

---

## Step 1 — Choose a unique `ForgeProjectSlug`

See [KIT_LAYOUT.md](KIT_LAYOUT.md). Example: `acme-billing-api`.
Rule: `<github_org>-<repo-name>` in lowercase with hyphens.
If two repos share a name, append a short disambiguator: `acme-billing-api-a3f9`.

The slug is recorded in `FORGE_IDENTITY.md` and used as the Obsidian path
`Forge/Projects/<ForgeProjectSlug>/`. Never reuse another project's slug.

---

## Step 2 — Run the adopt script (recommended)

The scripts copy all files from `templates/` in one pass, including agent
integration for both Cursor and Claude Code.

**Windows (Git Bash or PowerShell):**
```powershell
# PowerShell
.\scripts\forge-adopt.ps1 -TargetRepo 'D:\path\to\your-app' -Stack python

# Git Bash
./scripts/forge-adopt.sh --target /d/path/to/your-app --stack python
```

**Unix / macOS:**
```bash
./scripts/forge-adopt.sh --target /path/to/your-app --stack go
```

Available stacks: `minimal` · `python` · `node` · `go`

**What the script copies:**

| Source | Destination |
|--------|-------------|
| `templates/universal/CLAUDE.md` | `<repo>/CLAUDE.md` |
| `templates/universal/FORGE_IDENTITY.md.template` | `<repo>/FORGE_IDENTITY.md` |
| `templates/universal/RESEARCH.md.template` | `<repo>/RESEARCH.md` |
| `templates/universal/FORGE_SYSTEM.md.template` | `<repo>/FORGE_SYSTEM.md` |
| `templates/universal/PROJECT_LOG.md.template` | `<repo>/PROJECT_LOG.md` |
| `templates/stacks/<stack>/EVAL_SPEC.md` | `<repo>/EVAL_SPEC.md` |
| `templates/stacks/<stack>/EVAL.sh` | `<repo>/EVAL.sh` (chmod +x on Unix) |
| `templates/cursor/forge-v3.mdc` | `<repo>/.cursor/rules/forge-v3.mdc` |
| `templates/claude-code/CLAUDE.md` | `<repo>/.claude/CLAUDE.md` |
| `templates/claude-code/settings.json` | `<repo>/.claude/settings.json` |

---

## Step 3 — Fill identity and architecture

Edit `FORGE_IDENTITY.md`: set `ForgeProjectSlug`, `TechStack`, `PrimaryLanguage`,
and `ObsidianVaultRoot` (path to your Obsidian vault — see [OBSIDIAN_SETUP.md](OBSIDIAN_SETUP.md)).

Edit `FORGE_SYSTEM.md`: fill all six sections (Module map, Module contracts,
Scorecard rationale, Invariants, Known risks, Rollback notes template).
A blank `FORGE_SYSTEM.md` produces low-quality Auditor reviews — fill it fully now.

---

## Step 4 — Customize EVAL.sh

Open `EVAL.sh` in the target repo.

The stack templates measure TEST, QUAL, and DEBT automatically. PERF_SCORE is a
static placeholder (6.0). To wire a real performance benchmark, follow
[CUSTOMIZING_EVAL.md](CUSTOMIZING_EVAL.md).

Customize weights in `EVAL_SPEC.md` if your project's quality model differs from
the stack defaults. Document your reasoning in `FORGE_SYSTEM.md` under
**Scorecard rationale**.

---

## Step 5 — Establish baseline

In the target repo root, run EVAL.sh three times on **unchanged code**:

```bash
bash ./EVAL.sh && bash ./EVAL.sh && bash ./EVAL.sh
```

Record the **median** `SCORE` in `RESEARCH.md` under **Baseline Score** with a
timestamp. If the max−min spread across the three runs exceeds **0.3**, stop:
the harness is flaky. Fix `EVAL.sh` or the environment before cycling.

---

## Step 6 — Fill RESEARCH.md

Fill in the active hypothesis (all 8 required fields). The agent will output
`[FORGE] BLOCKED` and stop if any field is missing or placeholder-only.

Required fields:
`Hypothesis` · `Hypothesis Type` · `Confidence` · `Target File` · `Target Scope`
· `Baseline Score` · `Goal Score` · `Exploration Budget` · `Blocked Approaches`

---

## Step 7a — Cursor integration

After adoption, the repo contains `.cursor/rules/forge-v3.mdc` (copied by the
adopt script). Two options:

- **Per repo (default):** The `.mdc` file is scoped to this workspace automatically.
  Set `alwaysApply: true` in its frontmatter if you want it active without globs.
- **Global:** Merge the rule body into your user-level Cursor rules for Forge
  behavior in every workspace with a Quintet present.

See [CURSOR_RULES.md](CURSOR_RULES.md) for full details.

---

## Step 7b — Claude Code integration

After adoption, the repo contains `.claude/CLAUDE.md` and `.claude/settings.json`
(copied by the adopt script).

`.claude/CLAUDE.md` tells Claude Code:
- The startup gate (read FORGE_IDENTITY.md, then the Quintet in order)
- How to run EVAL.sh via the Bash tool
- How to read Obsidian pattern files
- Which tools are allowed during hypothesis cycles

`.claude/settings.json` provides example hooks (Stop reminder, optional PreToolUse
git-commit gate). Edit it to match your workflow; delete the `_comment` keys.

**Session start in Claude Code:** Open the adopted repo directory. Claude Code reads
`.claude/CLAUDE.md` first, then `CLAUDE.md` at the repo root. The startup gate
automatically runs the Forge initialization sequence.

---

## Step 8 — Obsidian project folder

In your vault (see [OBSIDIAN_SETUP.md](OBSIDIAN_SETUP.md)), duplicate
`Forge/Projects/_TEMPLATE_SLUG/` and rename it to
`Forge/Projects/<ForgeProjectSlug>/`. Update `00-Project-Index.md` with:
- Git remote URL
- Local clone path
- Path to `PROJECT_LOG.md` (outside the vault)

**Isolation:** During any session for this repo, only read this folder plus
`Forge/Patterns/`. Never query another project's subfolder.

---

## Updating an already-adopted repo (kit evolves)

When THE FORGE kit is updated, refresh methodology files without overwriting your
project state:

```powershell
# Windows
.\scripts\forge-update.ps1 -TargetRepo 'D:\path\to\your-app'

# Unix
./scripts/forge-update.sh --target /path/to/your-app
```

This updates `CLAUDE.md`, `.claude/`, and `.cursor/rules/forge-v3.mdc` only.
It does NOT touch `FORGE_IDENTITY.md`, `RESEARCH.md`, `FORGE_SYSTEM.md`,
or `PROJECT_LOG.md` — your project state is preserved.

To also refresh the EVAL harness (resets baseline — use carefully):

```bash
./scripts/forge-update.sh --target /path/to/your-app --stack python --update-eval
```

---

## Per-repository operations

The following are **scoped to each git repository** and its `PROJECT_LOG.md`:

- Cycle counter and Velocity Reports (every 5 cycles)
- Commits since last Auditor (trigger at every 5 commits)
- Pattern Distillation every 10 cycles using this repo's log plus global `Forge/Patterns/` only
- Stagnation: 3 consecutive velocity blocks with ≤ 40% win rate **in this repo's log**

Promoting a pattern to global `Forge/Patterns/` requires the v3 rule: seen on
**two or more distinct projects** before promotion.

---

## Keeping `CLAUDE.md` in sync

`templates/universal/CLAUDE.md` may evolve as the methodology is refined.
When the kit ships a new version:
1. Run `forge-update.*` (without `--update-eval`) in each adopted repo.
2. The footer `Kit template revision:` line in `CLAUDE.md` shows the version you have.
3. Review `docs/CHANGELOG.md` in the kit for breaking changes before updating.
