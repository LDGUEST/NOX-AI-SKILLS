---
name: context-engineer
description: Audits and governs all AI context files — health scoring, armor enforcement, bloat detection, cross-project drift. Use when syncing CLAUDE.md files, diagnosing context issues, or onboarding a project.
---

Discover, audit, and govern all AI context files across your projects. Goes beyond simple validation — enforces armor, scores health, detects cross-project drift, and asks the right questions to fill gaps. Built for solo developers juggling dozens of projects.

## When to Use

- Starting a session on a project you haven't touched in weeks
- After a multi-agent session where several AIs modified context files
- Periodic maintenance across all projects
- When context files feel bloated, stale, or contradictory
- When starting a new project and need proper context scaffolding

## Arguments

- *(empty)* — audit current project only
- `--all` — sweep all projects in workspace
- `--project <name>` — audit a specific project
- `--fix` — auto-propose fixes (still confirms before writing)
- `--score-only` — health dashboard only, no remediation
- `--codebase` — include codebase-level diagnostics (large files, import chains, security scan)

## Context File Registry

Scan for: CLAUDE.md, CLAUDE.local.md (deprecated — flag for migration), MEMORY.md, DEBUGGING.md, GEMINI.md, .cursorrules, .clinerules, .windsurfrules, .roomodes, copilot-instructions.md, AGENTS.md, .claude/settings.json

## Process

### Phase 1: Discovery
Find all context files at project root, subdirectories, and global config (~/.claude/, ~/.gemini/). For each, record: path, line count, last modified, armor status, size category (lean/normal/heavy/bloated).

### Phase 2: Diagnostics
Run structural and security checks on context files and (with `--codebase` or `--all`) the broader codebase. See [references/DIAGNOSTICS.md](references/DIAGNOSTICS.md) for bash commands and output format.

**Context file checks:** ❌ Circular references, ❌ Missing references, ⚠️ Duplicate references, ⚠️ Deep chains (>3 levels), 🔒 Exposed secrets

**Codebase checks (`--codebase`/`--all`):** ❌ Circular imports, ❌ Missing import files, ⚠️ Large files (>1MB), ⚠️ Deep import chains (>5), ⚠️ Duplicate imports, 🔒 Hardcoded secrets / .env not gitignored

Deductions: ❌ = -5 Accuracy, ⚠️ = -2 Bloat/Consistency, 🔒 = -10 Accuracy.

### Phase 3: Health Scoring (0-100)
| Dimension | Weight | What it measures |
|-----------|--------|-----------------|
| Completeness | 20 | Has essential files (CLAUDE.md, MEMORY.md, etc.) |
| Freshness | 20 | Files modified recently, no stale references |
| Accuracy | 20 | Tech stack matches package.json, env vars match code, diagnostic deductions |
| Protection | 15 | NOX-ARMOR headers present |
| Consistency | 15 | Matches global conventions, no contradictions |
| Bloat | 10 | Under line limits, no duplicates |

### Phase 4: Dashboard
```
Context Health Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━
Project                  Score   Grade   Issues
Scriber                  72/100  C       [no armor] [stale env vars]
GAV-Admin                88/100  B+      [1 stale entry]

DIAGNOSTICS:
  ❌ Circular refs: 0  ❌ Missing refs: 1  ⚠️ Large files: 2
  ⚠️ Deep chains: 0    ⚠️ Duplicates: 1    🔒 Security: 0
```

### Phase 5: Armor Check
For files without NOX-ARMOR, ask:
- CLAUDE.md: Which sections to lock? Max line count? Auto-expire sections?
- MEMORY.md: Max entries? Age threshold for flagging? Required categories?
- DEBUGGING.md: Archive solved bugs after N days? Lock attribution format?

Generate armor headers from answers. Confirm before writing.

### Phase 6: Remediation (--fix)
For each issue, propose exact fixes:
- Stale entries → update with current info
- Missing files → generate from codebase analysis (not blind templates)
- Bloat → propose restructure, deduplication
- Inconsistencies → align with global conventions
- Missing armor → run armor questionnaire

Always show diff and confirm before any write.

### Phase 7: Cross-Project Sync (--all only)
- Global patterns that should propagate to projects
- Convention drift across projects
- Orphaned global memories
- Missing subsystem CLAUDE.md files

## Rules

- Global system files (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `~/.gemini/GEMINI.md`) are read-only — scoring and consistency checks only. If the global CLAUDE.md exceeds 200 lines, flag the bloat and suggest what to move; don't add to it.
- Show the exact diff and confirm before modifying any file.
- Archive or flag context entries rather than deleting — lost history can't be recovered.
- Health scores must be verifiable. If a dimension can't be checked, score it 0 and say why.
- Generate missing CLAUDE.md files from actual codebase analysis, not blank templates.
- Respect existing armor — locked sections stay locked unless the user explicitly unlocks them.
- The Phase 5 armor questionnaire is required for first-time armor — skipping produces headers that don't reflect what the user wants protected.
- Use `[maybe stale]` when uncertain — silent removal is worse than a false positive.

---
Nox
