# Contributing to Nox

Thanks for your interest in contributing to Nox! This guide covers how to create skills, submit changes, and follow the project's conventions.

## Quick Start

1. Fork the repo and clone it
2. Create a feature branch: `git checkout -b feat/my-skill`
3. Make your changes (see formats below)
4. Run `bash validate.sh` to check format parity
5. Submit a PR

## Skill Format

Every skill must exist in **all 3 CLI formats**. Nox supports Claude Code, Gemini CLI, and Codex CLI.

### Claude Code (`claude/nox/<name>.md`)

Plain markdown. The filename becomes the slash command (`/nox:<name>`).

```markdown
Your skill prompt here. No frontmatter needed.

Claude Code reads this as a system-level instruction when the user invokes `/nox:<name>`.
```

### Gemini CLI (`gemini/skills/<name>/SKILL.md`)

YAML frontmatter + markdown body.

```markdown
---
name: <name>
description: One-line description of what this skill does
---

Your skill prompt here (same content as Claude version).
```

### Codex CLI (`codex/skills/<name>/SKILL.md`)

Plain markdown (same as Claude format). Each skill lives in its own directory.

```markdown
Your skill prompt here. Same content as Claude version.
```

### Keeping Formats in Sync

The content of all 3 formats should be functionally identical. The only difference is Gemini's YAML frontmatter. After making changes, run:

```bash
bash validate.sh
```

This checks that every skill exists in all 3 formats and flags any mismatches.

## Agent Format (`agents/<name>.md`)

Agents are Claude Code only (they use the Agent tool). YAML frontmatter + XML-sectioned markdown.

```markdown
---
name: <name>
description: What the agent does
tools:
  - Read
  - Grep
  - Glob
  - Bash
color: "#hexcolor"
---

<role>
Agent role description
</role>

<instructions>
Step-by-step instructions
</instructions>

<output>
Expected output format
</output>
```

## Hook Format (`hooks/<name>.sh`)

Hooks are Claude Code shell scripts. Follow these conventions:

- Shebang: `#!/bin/bash`
- Read JSON from stdin: `INPUT=$(cat)`
- Parse with python3: `echo "$INPUT" | python3 -c "import sys,json; ..."`
- Exit codes: `0` = allow, `2` = block (PreToolUse only)
- Config via env vars: `NOX_SKIP_<NAME>=1` to disable
- Always include: header comment with Install/Config/Platform info

## Naming

- Skills: lowercase, hyphenated if multi-word (`quick-phase`, `skill-create`)
- Agents: `nox-` prefix, hyphenated (`nox-reviewer`, `nox-security-scanner`)
- Hooks: lowercase, hyphenated (`destructive-guard`, `secret-scanner`)

## Categories

Skills are grouped into categories in the help-forge catalog:

| Category | Skills |
|----------|--------|
| Pipeline & Orchestration | full-phase, quick-phase, iterate, unloop |
| Code Quality | review, tdd, refactor, commit |
| Security & Reliability | security, audit, perf |
| Architecture & Design | architect, brainstorm, prompt, skill-create |
| DevOps & Deploy | cicd, deploy, push, migrate, changelog, monitorlive |
| Multi-Agent Coordination | syncagents, handoff, overwrite, context |
| Diagnostics | diagnose, uxtest, questions |
| Meta | help-forge, update, landing |

## PR Guidelines

- One skill per PR (unless they're tightly coupled)
- Include all 3 CLI formats
- Update `help-forge` in all 3 formats if adding a new skill
- Update `ROADMAP.md` if completing a roadmap item
- Run `bash validate.sh` before submitting

## Testing

There's no automated test suite — skills are prompt templates, not code. Test by:

1. Installing locally: `bash install.sh --symlink`
2. Running the skill in Claude Code: `/nox:<name>`
3. Verifying it produces the expected behavior

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
