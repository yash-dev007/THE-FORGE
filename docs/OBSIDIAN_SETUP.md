# Obsidian vault setup for THE FORGE

The Forge v3 uses Obsidian as persistent pattern memory shared across projects.
This guide covers setup, co-location options, and how Claude Code reads vault notes.

---

## What the vault stores

| Path | Contents | Access rules |
|------|----------|-------------|
| `Forge/Patterns/` | Global cross-project patterns | Any session may read; humans promote |
| `Forge/Projects/<slug>/` | Per-project context and hypothesis queue | This project's sessions only |

**Isolation is critical.** Claude Code must never read `Forge/Projects/<other-slug>/`
during a session for project A. See the Context Isolation Protocol in `CLAUDE.md`.

---

## Option 1 — Vault co-located with the kit repo (simplest)

If you keep THE FORGE repo and want it to also be your vault:

1. Open Obsidian → "Open folder as vault" → select `D:\Projects\THE FORGE` (or wherever
   the kit lives).
2. Obsidian creates `.obsidian/` at the kit root.
3. `Forge/Patterns/` and `Forge/Projects/` already exist — they will appear in Obsidian.
4. In every `FORGE_IDENTITY.md`, set:
   ```yaml
   ObsidianVaultRoot: "D:/Projects/THE FORGE"
   ```

**Pros:** No extra folder; kit and vault stay in sync.
**Cons:** Adopted project code and vault notes are in the same commit history if the kit
is a git repo (use `.gitignore` to exclude `.obsidian/` if desired).

---

## Option 2 — Separate vault folder (recommended for teams)

1. Create a dedicated folder, e.g. `D:\Vaults\forge-memory`.
2. Open Obsidian → "Open folder as vault" → select that folder.
3. Copy `Forge/` from the kit into the vault root:
   ```powershell
   Copy-Item -Recurse "D:\Projects\THE FORGE\Forge" "D:\Vaults\forge-memory\Forge"
   ```
   Or on Unix:
   ```bash
   cp -r /path/to/the-forge/Forge /path/to/vault/Forge
   ```
4. In every `FORGE_IDENTITY.md`, set:
   ```yaml
   ObsidianVaultRoot: "D:/Vaults/forge-memory"
   ```

**Pros:** Clean separation; vault can be synced independently (iCloud, Dropbox, git).
**Cons:** Must manually copy `Forge/` from the kit on first setup.

---

## Option 3 — No Obsidian (minimal setup)

If you skip Obsidian entirely:
- Leave `ObsidianVaultRoot: ""` in `FORGE_IDENTITY.md`.
- Claude Code will emit `[FORGE] WARN: ObsidianVaultRoot not set — pattern memory disabled`
  and skip all pattern queries.
- You can still run full hypothesis cycles; you just lose cross-project pattern memory.
- Promote patterns manually by editing Markdown files in `Forge/Patterns/` directly.

---

## How Claude Code reads Obsidian notes

Claude Code accesses Obsidian notes as **plain Markdown files** using the Read tool.
No MCP server or Obsidian plugin is required for basic usage.

```
# Claude Code reads pattern notes like this:
Read: <ObsidianVaultRoot>/Forge/Patterns/profile-before-vectorizing.md
Read: <ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/00-Project-Index.md
```

The `ObsidianVaultRoot` field in `FORGE_IDENTITY.md` provides the base path.
All paths are constructed as `<ObsidianVaultRoot>/Forge/Patterns/` and
`<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/`.

### Optional: Obsidian MCP server

For richer Obsidian integration (backlinks, graph queries, search):
- Install the Obsidian Local REST API plugin or `obsidian-mcp`.
- Add it to your Claude Code MCP config.
- Update `templates/claude-code/FORGE_BRIDGE.md` in your adopted repo to use MCP calls
  instead of direct file reads.

The kit does not require an MCP server — direct reads are sufficient for the
pattern-matching workflow described in v3.

---

## Setting up a new project folder in the vault

When adopting Forge into a new repo (see `docs/ADOPT.md` Step 5):

1. In your vault, open `Forge/Projects/`.
2. Duplicate `_TEMPLATE_SLUG/` and rename the copy to `<ForgeProjectSlug>`.
3. Open `<ForgeProjectSlug>/00-Project-Index.md` and fill in:
   - Git remote URL
   - Local clone path
   - Path to `PROJECT_LOG.md` (outside the vault, in the adopted repo)
4. The `forge-adopt` scripts do **not** create the vault folder automatically — this
   step is intentionally manual so you control slug uniqueness.

---

## Pattern note schema

Every note in `Forge/Patterns/` must follow this schema (from v3 `CLAUDE.md`):

```markdown
# Pattern: [Name]
**Domain:** [Performance / Correctness / Debt / Architecture]
**Mechanism:** [One sentence: what makes this work]
**Applies When:** [Conditions]
**Does Not Apply When:** [Counter-conditions — critical]
**Confirmation Count:** [N]
**Projects:** [list of ForgeProjectSlugs]
**Last Updated:** [YYYY-MM-DD]
```

See `Forge/Patterns/_example-performance-pattern.md` for a complete example.

---

## Pattern promotion workflow

Patterns start in the project folder and graduate to global:

```
PROJECT_LOG.md cycle entry
  → Claude notices "Pattern Signal" in log entry
  → If seen only in this project:
       write to Forge/Projects/<slug>/ as a new note
  → If confirmed on 2+ distinct projects:
       promote to Forge/Patterns/ as a new note
       list both projects in the "Projects:" field
  → On every subsequent confirmation:
       increment "Confirmation Count" in the global note
       add the project to "Projects:" list
```

**Human responsibility:** Pattern promotion always requires a human to move the note
from the project folder to `Forge/Patterns/`. Agents propose; humans decide.

---

## Vault sync recommendations

| Setup | Sync method |
|-------|-------------|
| Solo developer | Dropbox / iCloud (Obsidian built-in sync) |
| Small team | Obsidian Sync (paid) or git-based vault |
| Large team | Dedicated git repo for the vault; CI validates pattern schema |

If using git for the vault, add `.obsidian/workspace` and `.obsidian/cache` to
`.gitignore` to avoid noisy diffs from Obsidian's UI state.
