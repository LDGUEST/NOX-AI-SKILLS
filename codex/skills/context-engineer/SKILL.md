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

## Context File Registry

Scan for: CLAUDE.md, MEMORY.md, DEBUGGING.md, GEMINI.md, .cursorrules, .clinerules, .windsurfrules, .roomodes, copilot-instructions.md, AGENTS.md, .claude/settings.json

## Process

### Phase 1: Discovery
Find all context files at project root, subdirectories, and global config. For each, record: path, line count, last modified, armor status, size category (lean/normal/heavy/bloated).

### Phase 2: Health Scoring (0-100)
| Dimension | Weight | What it measures |
|-----------|--------|-----------------|
| Completeness | 20 | Has essential files (CLAUDE.md, MEMORY.md, etc.) |
| Freshness | 20 | Files modified recently, no stale references |
| Accuracy | 20 | Tech stack matches package.json, env vars match code |
| Protection | 15 | NOX-ARMOR headers present |
| Consistency | 15 | Matches global conventions, no contradictions |
| Bloat | 10 | Under line limits, no duplicates |

### Phase 3: Dashboard
```
Context Health Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━
Project                  Score   Grade   Issues
Scriber                  72/100  C       [no armor] [stale env vars]
GAV-Admin                88/100  B+      [1 stale entry]
```

### Phase 4: Armor Check
For files without NOX-ARMOR, ask targeted questions per file type, generate armor headers, confirm before writing.

### Phase 5: Remediation (--fix)
Propose exact fixes for stale entries, missing files, bloat, inconsistencies, missing armor. Always show diff and confirm.

### Phase 6: Cross-Project Sync (--all only)
Check global pattern propagation, convention drift, orphaned memories, missing subsystem context files.

## Rules

- NEVER modify files without showing diff and getting confirmation
- NEVER delete context entries — only update, archive, or flag
- NEVER fabricate health scores — if unverifiable, score 0 and note why
- Generate missing files from actual codebase analysis, not blind templates
- Respect existing armor — LOCKED sections are off-limits
- Armor questionnaire is mandatory for first-time armor
- Use `[maybe stale]` when uncertain

---
Nox
