# THE FORGE — Multi-Platform Guide

THE FORGE v4 is agent-agnostic. The same loop driver (`forge-cycle.sh`) runs on
every platform. Platform bridge files handle startup gating, tool syntax, and
skill invocation in platform-native formats.

---

## Platform overview

| Platform | Bridge file in adopted repo | Format | How it invokes forge-cycle.sh |
|----------|-----------------------------|--------|-------------------------------|
| **Claude Code** | `.claude/CLAUDE.md` | Markdown | Bash tool: `bash ./forge-cycle.sh` |
| **Gemini CLI** | `GEMINI.md` | Markdown | `run_shell_command` tool |
| **Cursor** | `.cursor/rules/forge.mdc` | MDC rule | Terminal panel / composer |
| **Codex** | `program.md` | Markdown | Shell tool |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Markdown | Terminal |

All platforms use the **same** forge-cycle.sh core — no duplicated logic.

---

## Claude Code

### What's copied on adoption
```
.claude/
  CLAUDE.md          ← Startup gate + forge-cycle.sh invocation
  settings.json      ← Example hooks (PostToolUse, Stop)
  skills/
    forge-cycle.md   ← /forge-cycle slash command
```

### Starting a session
Claude Code reads `.claude/CLAUDE.md` automatically. The startup gate validates
the Quintet and sets `BASELINE_SCORE`.

### Running a cycle
```
/forge-cycle
```
Or invoke manually via the Bash tool:
```bash
bash ./forge-cycle.sh --baseline-only
# ... implement hypothesis ...
bash ./forge-cycle.sh --skip-baseline 6.50
```

### Settings
`settings.json` ships with example hooks. Edit to taste — common additions:
- PostToolUse hook running `bash EVAL.sh` after file edits
- Stop hook printing a cycle summary

---

## Gemini CLI

### What's copied on adoption
```
GEMINI.md            ← Startup gate + forge-cycle.sh invocation + Obsidian access
```

### Starting a session
Gemini CLI reads `GEMINI.md` at the repo root automatically. Follow the startup
gate sequence in the file.

### Running a cycle
```python
# Gemini CLI tool syntax
run_shell_command("bash ./forge-cycle.sh --baseline-only")
# ... implement hypothesis ...
run_shell_command("bash ./forge-cycle.sh --skip-baseline 6.50")
```

### Obsidian pattern access
```python
read_file("/path/to/vault/Forge/Patterns/python-profile-before-optimize.md")
```

---

## Cursor

### What's copied on adoption
```
.cursor/rules/
  forge.mdc          ← MDC rule: startup gate + cycle protocol
```

### Starting a session
Cursor loads `.cursor/rules/forge.mdc` automatically for the workspace. The rule
activates when you open the adopted repo.

### Running a cycle
Use the Cursor composer or terminal panel:
```bash
bash ./forge-cycle.sh --baseline-only
# ... implement hypothesis ...
bash ./forge-cycle.sh --skip-baseline 6.50
```

### Scope control
The `forge.mdc` rule's `globs` field controls which files activate the rule.
Default: `**/*` (all files in the workspace).

See [CURSOR_RULES.md](CURSOR_RULES.md) for user-level vs per-repo scope options.

---

## Codex

### What's copied on adoption
```
program.md           ← Codex startup gate + cycle protocol
```

### Starting a session
Codex reads `program.md` at session start. The startup gate validates the Quintet
and establishes baseline.

### Running a cycle
```bash
bash ./forge-cycle.sh --baseline-only
# ... implement hypothesis ...
bash ./forge-cycle.sh --skip-baseline 6.50
```

### Tool permissions
`program.md` lists allowed tools. The key permission is `shell` — ensure Codex
has permission to run bash commands before starting a Forge session.

---

## GitHub Copilot (Workspace Instructions)

### What's copied on adoption
```
.github/
  copilot-instructions.md  ← Workspace instructions: startup gate + cycle protocol
```

### Starting a session
Copilot reads `.github/copilot-instructions.md` for workspace-level instructions.
The file tells Copilot to follow the Forge protocol when working in this repo.

### Running a cycle
Use the VS Code terminal:
```bash
bash ./forge-cycle.sh --baseline-only
# ... implement hypothesis ...
bash ./forge-cycle.sh --skip-baseline 6.50
```

### Limitations
Copilot workspace instructions are advisory — Copilot does not execute shell
commands autonomously. The cycle script must be run manually in the terminal.
Copilot's role is hypothesis generation and code implementation; measurement is
handled by the terminal.

---

## Selecting platforms on adoption

Use `--platforms` (bash) or `-Platforms` (PowerShell) to copy only the platforms
you use. Default: all platforms.

```bash
# Only Claude Code + Gemini
bash scripts/forge-adopt.sh --target ./my-app --platforms claude,gemini

# All platforms (default)
bash scripts/forge-adopt.sh --target ./my-app
```

```powershell
# Only Cursor + Codex
.\scripts\forge-adopt.ps1 -TargetRepo 'D:\my-app' -Platforms "cursor,codex"
```

---

## Updating platform templates

When THE FORGE kit ships a new platform template version:

```bash
./scripts/forge-update.sh --target /path/to/app
```

This refreshes all platform bridge files (`.claude/CLAUDE.md`, `GEMINI.md`,
`forge.mdc`, `program.md`, `.github/copilot-instructions.md`) and the loop driver
scripts (`forge-cycle.sh`, `forge-obsidian-sync.sh`, `forge-chart.py`).

Project state files (`FORGE_IDENTITY.md`, `RESEARCH.md`, `FORGE_SYSTEM.md`,
`PROJECT_LOG.md`) are never touched by `forge-update.*`.

---

## Adding a new platform

To add support for a new AI platform:

1. Create `templates/<platform-name>/` in the kit repo.
2. Add a bridge file following the same 8-step startup gate as existing templates.
3. Update `forge-adopt.sh` and `forge-adopt.ps1` to copy the template when the
   platform is in `--platforms`.
4. Update `forge-update.sh` and `forge-update.ps1` to refresh the bridge file.
5. Document the platform here and in `KIT_LAYOUT.md`.
