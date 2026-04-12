<div align="center">

# ⚒ THE FORGE

**The AI Research Engineer Workflow Kit — for every codebase that deserves better.**

*Diagnose · Hypothesize · Execute · Verify · Synthesize*

[![Version](https://img.shields.io/badge/version-v3.1-blueviolet?style=flat-square)](docs/CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](#license)
[![Stacks](https://img.shields.io/badge/stacks-Python%20%7C%20Node%20%7C%20Go%20%7C%20Minimal-green?style=flat-square)](#stacks)
[![Agent Support](https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Cursor-orange?style=flat-square)](#agent-integration)

</div>

---

## What is THE FORGE?

Imagine you hired a brilliant senior engineer who, instead of just writing code and hoping for the best, **runs experiments**. Before touching anything, they form a precise hypothesis about *why* something is slow or broken. They measure the baseline. They make exactly one change. They measure again. If it worked, they commit and document *why* it worked. If it didn't, they log what they learned and try the next idea.

That's THE FORGE.

**THE FORGE is a portable workflow kit** that turns your AI coding assistant (Claude Code or Cursor) into that disciplined scientist. You drop it into any codebase — a Python API, a Node.js service, a Go microservice — and your AI agent stops guessing and starts doing *repeatable research*.

It is not a product. It is not a framework your code depends on. It's a **methodology kit**: a set of files and scripts you copy into your project that tell the AI exactly how to think, how to measure, and when to stop.

---

## Why does this exist?

AI coding assistants are powerful but undisciplined. Left to their own devices, they:

- Make changes without measuring whether they helped
- Repeat the same failed approaches with slightly different code
- Optimize one thing while silently breaking another
- Forget what they tried last session

THE FORGE fixes this with five principles:

| Problem | Forge Solution |
|---------|---------------|
| "Just make it faster" | Falsifiable hypothesis with a specific mechanism |
| Unmeasured changes | EVAL.sh runs 3× before any commit decision |
| Gaming one metric | 4-dimensional composite score (Performance + Quality + Tests + Debt) |
| Repeated failures | `Blocked Approaches` field — never retry what already failed |
| Session amnesia | Obsidian vault: cross-project pattern memory that compounds over time |

---

## Hypothetical Scenarios

*These are illustrative examples showing how THE FORGE would be used in real-world situations.*

---

### 🐢 Scenario 1 — "Our API is slow and we don't know why"

**The team:** A 3-person startup building a real-time analytics dashboard. Their `/reports` endpoint takes 4 seconds. Users are leaving.

**Without THE FORGE:** The developer asks Claude Code to "make the API faster." Claude rewrites the database queries, adds caching, changes the serializer — all in one session. The endpoint is now 3.8 seconds. Nobody knows what worked. The next developer who touches it breaks it.

**With THE FORGE:**
1. They run `./EVAL.sh` three times. Baseline SCORE: 4.2 / 10.
2. Claude Code says: *"PERF_SCORE is 2.1. Hypothesis: The bottleneck is the N+1 query in `reports/generator.py:L88` — replacing it with a single JOIN will reduce per-request DB round trips from 47 to 1."*
3. One change. One re-run. New SCORE: 6.8. COMMIT.
4. Cycle 2: *"Hypothesis: The serializer at `reports/serializer.py:L34` allocates a new dict per row — pre-allocating with a list comprehension will eliminate GC pressure."*
5. Two weeks later, their `/reports` endpoint takes 0.6 seconds. They have 8 log entries, each explaining *exactly* what worked and why.

**The difference:** Not just a faster endpoint — a **documented, reproducible improvement history** that any new developer can read and continue.

---

### 🧹 Scenario 2 — "We inherited 40,000 lines of spaghetti code"

**The situation:** A fintech company acquired a startup. The startup's codebase has zero tests, functions 300 lines long, and cyclomatic complexity that would make a seasoned engineer cry.

**Without THE FORGE:** The new team spends three months "refactoring" — moving code around, renaming things, occasionally breaking production.

**With THE FORGE:**
1. Baseline SCORE: 3.1 / 10 (DEBT_SCORE: 1.8, TEST_SCORE: 0.0).
2. Hypothesis Type: **Debt**. First hypothesis: *"Function `process_transaction()` in `payments/core.py:L142` has CC 28 — extracting the validation branch into `_validate_payment_data()` will reduce CC to ≤ 10."*
3. Each cycle: one function, one refactor, measured improvement.
4. After 20 cycles spanning two months: SCORE 6.4. Every refactor documented. No mystery regressions.
5. The Auditor Protocol catches a hidden coupling that snuck in at Cycle 17 — before it reaches production.

**The difference:** Debt is reduced *systematically and measurably*, not through vibes.

---

### 🤖 Scenario 3 — "Our ML pipeline takes 6 hours per training run"

**The situation:** A solo data scientist at a research lab. Her image-processing pipeline runs overnight, and she can only try one idea per day.

**Without THE FORGE:** She tries vectorizing numpy loops, then switching to PyTorch, then adding a GPU step — all in the same week, with no record of what each change actually did to runtime.

**With THE FORGE:**
1. She installs the Python stack. PERF_SCORE is wired to `hyperfine` running a 100-image benchmark subset.
2. Cycle 1: *"The bottleneck is `chroma_key.py:L142` — branch prediction failures in a nested loop. Replacing with a vectorized NumPy operation is expected to reduce per-frame latency by ~40%."*
3. Runs EVAL.sh × 3. Actual delta: PERF_SCORE 5.2 → 7.1. **COMMIT**.
4. Cycle 2: Architecture hypothesis (required every 10th cycle): *"Replacing the sequential frame processor with a queue-based worker pool will allow GPU parallelism."*
5. Pattern Distillation after 10 cycles promotes *"vectorized NumPy outperforms branching loops on array shapes > 1000"* to the global Obsidian vault.

Two months later, she starts a new project. That Obsidian pattern is already there, **with a confidence count of 1** — it informs her first hypothesis on day one.

**The difference:** She's not just faster — she's building a **compound knowledge base** that gets more valuable with every project.

---

### 🏢 Scenario 4 — "We need to refactor our monolith into microservices"

**The situation:** A 15-person engineering team. Their Node.js monolith handles payments, notifications, and user management. They need to extract the payments module — but every time they've tried before, something unexpected breaks.

**Without THE FORGE:** They schedule a "big bang" refactor sprint, break three unrelated features, roll back, and add it to the "maybe Q3" backlog.

**With THE FORGE:**
1. Architecture-type hypothesis: *"Extracting the payments module via a message queue between `PaymentProcessor` and `NotificationService` will decouple them without breaking existing event ordering."*
2. FORGE_SYSTEM.md captures the current coupling contracts: `payments/ must NOT import from notifications/`.
3. Claude Code requires human approval before any Architecture change — the team reviews together.
4. Rollback plan is documented *before* any code is written.
5. The Auditor Protocol runs after every 5 commits — a fresh agent context checks whether the extraction is moving toward or away from the target architecture.

**The difference:** A risky architectural change is broken into **verified, reversible steps** with a human checkpoint at every gate.

---

## How It Works

THE FORGE is structured around five concepts:

```
┌─────────────────────────────────────────────────────┐
│  Every session starts here                          │
│                                                     │
│  1. Read your project files (the "Quintet")         │
│  2. Measure the current state (EVAL.sh × 3)         │
│  3. Propose 3 hypotheses — human picks one          │
└──────────────────┬──────────────────────────────────┘
                   │
          ┌────────▼────────┐
          │    DIAGNOSE     │  What is causing the problem?
          └────────┬────────┘
                   │
          ┌────────▼────────┐
          │   HYPOTHESIZE   │  One change. One variable.
          └────────┬────────┘
                   │
          ┌────────▼────────┐
          │    EXECUTE      │  Make the change.
          └────────┬────────┘
                   │
          ┌────────▼────────┐
          │    VERIFY       │  EVAL.sh × 3. Check anti-gaming rules.
          └────────┬────────┘
                   │
           Better? ──► COMMIT + LOG WIN
           Worse?  ──► REVERT + LOG FAILURE
                   │
          ┌────────▼────────┐
          │   SYNTHESIZE    │  Update the log. Promote patterns. Repeat.
          └─────────────────┘
```

### The Quintet — five files every project keeps

| File | What it does |
|------|-------------|
| `CLAUDE.md` | The operating manual — rules, loop structure, anti-gaming policies |
| `RESEARCH.md` | The active hypothesis — what are you testing right now, and why |
| `EVAL_SPEC.md` | The scorecard — what dimensions matter and how they're weighted |
| `EVAL.sh` | The judge — runs your test suite, linter, and complexity checks |
| `FORGE_SYSTEM.md` | The architecture map — what exists, what must not be coupled |
| `PROJECT_LOG.md` | The memory — every cycle: what was tried, what happened, and what it rules out |

### The Score — four dimensions, one composite

Every EVAL.sh run produces five lines:

```
PERF_SCORE:  8.2   ← Is it fast enough?
QUAL_SCORE:  9.0   ← Is the code clean?
TEST_SCORE: 10.0   ← Do the tests pass?
DEBT_SCORE:  6.5   ← Is complexity under control?
SCORE:       8.6   ← Weighted composite (the number that matters)
```

No single dimension can be gamed without the others detecting it.

---

## Getting Started

### 1. Adopt Forge into your project

**Windows:**
```powershell
.\scripts\forge-adopt.ps1 -TargetRepo 'D:\path\to\your-project' -Stack python
```

**macOS / Linux / Git Bash:**
```bash
./scripts/forge-adopt.sh --target /path/to/your-project --stack node
```

Available stacks: `python` · `node` · `go` · `minimal`

### 2. Fill in your project identity

Edit `FORGE_IDENTITY.md` in your project root:
```yaml
ForgeProjectSlug: "mycompany-my-api"
ProjectDisplayName: "My API"
TechStack: "Python 3.12 · FastAPI · PostgreSQL"
PrimaryLanguage: "Python"
ObsidianVaultRoot: "/path/to/your/obsidian/vault"
```

### 3. Describe your architecture

Edit `FORGE_SYSTEM.md` — fill in your modules, what they can and cannot depend on,
and why your scorecard weights are set the way they are. This is what the Auditor
reads to catch hidden regressions.

### 4. Write your first hypothesis

Edit `RESEARCH.md`:
```markdown
## Hypothesis
Replacing the nested loop in reports/generator.py:L88 with a single JOIN query
will reduce per-request database round trips from 47 to 1.

## Hypothesis Type
Performance

## Confidence
High
```

### 5. Establish your baseline

```bash
bash ./EVAL.sh   # Run once
bash ./EVAL.sh   # Run twice
bash ./EVAL.sh   # Run three times — take the median
```

Record the median `SCORE` in `RESEARCH.md` under `Baseline Score`. You're ready.

---

## Stacks

| Stack | Tests | Quality | Debt | Performance |
|-------|-------|---------|------|-------------|
| `python` | pytest | ruff | radon cyclomatic complexity | placeholder — [wire your benchmark](docs/CUSTOMIZING_EVAL.md) |
| `node` | npm test | eslint | eslint complexity rule | placeholder |
| `go` | go test | golangci-lint | gocyclo | placeholder |
| `minimal` | noop | noop | noop | noop — wire all four |

**PERF_SCORE** is intentionally a placeholder in all stacks — performance benchmarks are too project-specific to pre-configure. See [docs/CUSTOMIZING_EVAL.md](docs/CUSTOMIZING_EVAL.md) for step-by-step wiring instructions.

---

## Agent Integration

### Claude Code

After adoption, your project contains `.claude/CLAUDE.md`. This tells Claude Code:
- How to run the startup sequence (read the Quintet, establish baseline)
- How to run `EVAL.sh` via the Bash tool
- Which files it may and may not edit during a hypothesis cycle
- How to read Obsidian pattern notes as plain Markdown files

No MCP server required for basic usage — Claude Code reads vault notes directly.

### Cursor

After adoption, your project contains `.cursor/rules/forge-v3.mdc`. This tells Cursor:
- To detect Forge projects automatically (presence of `RESEARCH.md` + `EVAL_SPEC.md` + `EVAL.sh`)
- To start every session with the Quintet startup sequence
- To enforce the `[FORGE]` status line on every response

See [docs/CURSOR_RULES.md](docs/CURSOR_RULES.md) for per-repo vs. global rule options.

---

## Obsidian Integration

THE FORGE uses Obsidian as a **persistent pattern memory** shared across all your projects.

```
Your Obsidian vault/
├── Forge/
│   ├── Patterns/          ← Cross-project insights (global)
│   │   ├── profile-before-vectorizing.md
│   │   └── join-beats-n-plus-one.md
│   └── Projects/
│       ├── mycompany-api/ ← This project's context only
│       └── startup-ml/    ← Another project's context only
```

Every 10 cycles, the AI reviews what it learned and asks: does this confirm, contradict,
or extend a known pattern? Patterns that appear in two or more projects get promoted to
`Forge/Patterns/` — and become available for every future project.

**Isolation is enforced:** During a session for Project A, the AI may never read Project B's
folder. Context poisoning is a first-class concern.

See [docs/OBSIDIAN_SETUP.md](docs/OBSIDIAN_SETUP.md) for vault setup options.

---

## Kit Structure

```
THE FORGE/
├── CLAUDE.md                        ← Kit workspace context (for Claude Code)
├── cursor.md                        ← Kit workspace notes (for Cursor)
├── README.md                        ← This file
│
├── templates/
│   ├── universal/                   ← Files copied to every adopted project
│   │   ├── CLAUDE.md                ← v3 operating rules (canonical text)
│   │   ├── FORGE_IDENTITY.md.template
│   │   ├── RESEARCH.md.template
│   │   ├── FORGE_SYSTEM.md.template
│   │   └── PROJECT_LOG.md.template
│   ├── stacks/
│   │   ├── python/                  ← pytest · ruff · radon
│   │   ├── node/                    ← npm test · eslint · complexity
│   │   ├── go/                      ← go test · golangci-lint · gocyclo
│   │   └── minimal/                 ← noop harness (wire manually)
│   ├── claude-code/                 ← Copied to <project>/.claude/
│   │   ├── CLAUDE.md
│   │   └── settings.json
│   └── cursor/
│       └── forge-v3.mdc             ← Copied to <project>/.cursor/rules/
│
├── scripts/
│   ├── forge-adopt.sh / .ps1        ← First-time adoption
│   └── forge-update.sh / .ps1       ← Refresh methodology (preserves project state)
│
├── docs/
│   ├── ADOPT.md                     ← Step-by-step adoption playbook
│   ├── KIT_LAYOUT.md                ← Full directory map
│   ├── CUSTOMIZING_EVAL.md          ← Wiring real PERF_SCORE benchmarks
│   ├── OBSIDIAN_SETUP.md            ← Vault setup + Claude Code integration
│   ├── CURSOR_RULES.md              ← Cursor rule options
│   ├── OPS_PER_REPO.md              ← Per-repo cadence rules
│   └── CHANGELOG.md                 ← Kit revision history
│
└── Forge/
    ├── Patterns/                    ← Obsidian: global cross-project patterns
    └── Projects/
        └── _TEMPLATE_SLUG/          ← Obsidian: per-project folder template
```

---

## Keeping Your Projects Up to Date

As THE FORGE kit evolves, refresh your adopted projects without touching your
hypothesis state:

```bash
# Refresh CLAUDE.md + agent integration only (safe — preserves all project state)
./scripts/forge-update.sh --target /path/to/your-project

# Also refresh EVAL harness (resets baseline — use deliberately)
./scripts/forge-update.sh --target /path/to/your-project --stack python --update-eval
```

The update scripts never overwrite `RESEARCH.md`, `PROJECT_LOG.md`,
`FORGE_IDENTITY.md`, or `FORGE_SYSTEM.md` — your project's memory is yours.

---

## Design Principles

**One change, one variable.** The scientific method applied to software. You cannot
understand causality if you change five things at once.

**Scores are a means, not an end.** Anti-gaming rules exist because metrics can be gamed.
The composite score makes that much harder. The Auditor catches what slips through.

**Failure is data.** A REVERT is not a setback — it is negative knowledge. Knowing that
vectorizing a function doesn't help *because the bottleneck is memory allocation, not
computation* is worth more than a random 0.2-point improvement with no explanation.

**Memory compounds.** The real return on THE FORGE is not cycle 1 — it's cycle 50,
when you have a pattern library that says: *"On this team, with this stack,
this category of optimization works 70% of the time. This one works 20%."*

---

## Documentation

| Doc | Purpose |
|-----|---------|
| [docs/ADOPT.md](docs/ADOPT.md) | Full adoption playbook (8 steps) |
| [docs/CUSTOMIZING_EVAL.md](docs/CUSTOMIZING_EVAL.md) | Wiring real PERF_SCORE benchmarks |
| [docs/OBSIDIAN_SETUP.md](docs/OBSIDIAN_SETUP.md) | Vault setup and Claude Code integration |
| [docs/KIT_LAYOUT.md](docs/KIT_LAYOUT.md) | Complete directory map |
| [docs/OPS_PER_REPO.md](docs/OPS_PER_REPO.md) | Per-repo cadence and Auditor rules |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Kit revision history |

---

## License

MIT — use it, fork it, adapt it to your team's workflow.

---

<div align="center">

*The Forge v3 — Built to compound. Designed to self-correct. Engineered by Yash.*

*"A system that improves code must first be honest about how code fails."*

</div>
