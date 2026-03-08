---
name: armor
description: Add protection headers and safe-modification instructions to files and subsystems
---

Add protection headers and safe-modification instructions to files and subsystems. Use when code is battle-tested and must not be casually modified by future agents or sessions.

## When to Use

- After stabilizing a critical subsystem (scanners, pipelines, engines, utilities)
- When a file has a history of being broken by AI "improvements"
- When the user says "lock this down", "protect this", or "armor this"
- After fixing a hard bug that should never be reintroduced
- On context files (CLAUDE.md, MEMORY.md) to prevent agent drift and bloat

## Arguments

`$ARGUMENTS` — Target: file path(s), directory, or subsystem name. If empty, ask what to protect.

## Process

### Step 1: Identify targets

If given a directory or subsystem name, find all critical files. Read the first 30 lines of each to check for existing PROTECTED MODULE headers or `NOX-ARMOR` comments. Skip already-armored files.

### Step 2: Gather context per file

For each unprotected file:
1. What it does — read existing docstring/header/first 50 lines
2. Who uses it — grep for imports/references across the project
3. What it depends on — read imports/requires
4. Known bugs — check `git log --oneline -20 -- <file>`
5. Hardcoded safety values — thresholds, caps, rate limits, critical constants

### Step 3: Write protection header

**For code files** — insert/replace top-level comment:
```
PROTECTED MODULE — DO NOT modify without explicit permission from the project owner.
<What breaks if this file breaks.>
HARD RULES:
  - <Specific invariant and WHY>
KNOWN BUG HISTORY:
  - <date>: <what broke> — <root cause> (fixed)
```

**For context files (.md)** — insert at top:
```markdown
<!-- NOX-ARMOR v1 | locked: <sections> | max-lines: <N> | audit: <YYYY-MM-DD> -->
```
Mark sections as `<!-- LOCKED -->` or `<!-- MUTABLE -->`. Ask the user which sections to lock.

**For config files** — add `_armor` key or top-level comment.

Rules: Be specific (exact values, real incidents). Never fabricate bug history. Name downstream consequences.

### Step 4: Update nearest CLAUDE.md

Add Protected Modules table and "How To Safely Modify" section with:
- Read-before-write protocol
- Surgical change rules
- Verification steps
- Safe changes vs changes needing approval

### Step 5: Verify and report

Run language-appropriate syntax/lint checks. Print summary:
```
ARMOR REPORT
━━━━━━━━━━━━
Files armored: N
  ✓ file1.ts (NEW)    ⊘ file2.py (SKIP — already protected)
CLAUDE.md updates: ...
Verification: all files pass
```

## Rules

- NEVER remove existing PROTECTED headers — only add or strengthen
- NEVER armor test files unless specifically asked
- Always read git history before writing bug history
- No bug history? Write "No known incidents yet" — do NOT fabricate
- For context files, ALWAYS ask which sections to lock vs leave mutable
- The `NOX-ARMOR` comment in markdown must be valid HTML comment on line 1

---
Nox
