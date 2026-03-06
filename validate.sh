#!/usr/bin/env bash
set -eu
(set -o pipefail 2>/dev/null) && set -o pipefail

# Nox Validator — confirms all 3 CLI formats are in sync
# Usage: bash validate.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$SCRIPT_DIR/claude/nox"
GEMINI_DIR="$SCRIPT_DIR/gemini/skills"
CODEX_DIR="$SCRIPT_DIR/codex/skills"
AGENTS_DIR="$SCRIPT_DIR/agents"
HOOKS_DIR="$SCRIPT_DIR/hooks"

errors=0
warnings=0

echo "Nox Validator"
echo "============="
echo ""

# ── Skill Parity ─────────────────────────────────────────────
echo "Checking skill parity across CLIs..."
echo ""

# Get all skill names from each format
claude_skills=""
if [ -d "$CLAUDE_DIR" ]; then
  claude_skills=$(ls -1 "$CLAUDE_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | sort)
fi

gemini_skills=""
if [ -d "$GEMINI_DIR" ]; then
  gemini_skills=$(ls -1d "$GEMINI_DIR"/*/ 2>/dev/null | xargs -I{} basename {} | sort)
fi

codex_skills=""
if [ -d "$CODEX_DIR" ]; then
  codex_skills=$(ls -1d "$CODEX_DIR"/*/ 2>/dev/null | xargs -I{} basename {} | sort)
fi

claude_count=$(echo "$claude_skills" | grep -c . 2>/dev/null || echo 0)
gemini_count=$(echo "$gemini_skills" | grep -c . 2>/dev/null || echo 0)
codex_count=$(echo "$codex_skills" | grep -c . 2>/dev/null || echo 0)

echo "  Claude: $claude_count skills"
echo "  Gemini: $gemini_count skills"
echo "  Codex:  $codex_count skills"
echo ""

# Check for skills missing from any format
all_skills=$(echo -e "$claude_skills\n$gemini_skills\n$codex_skills" | sort -u | grep .)

for skill in $all_skills; do
  missing=""
  [ -f "$CLAUDE_DIR/$skill.md" ] || missing="${missing} Claude"
  [ -f "$GEMINI_DIR/$skill/SKILL.md" ] || missing="${missing} Gemini"
  [ -f "$CODEX_DIR/$skill/SKILL.md" ] || missing="${missing} Codex"

  if [ -n "$missing" ]; then
    echo "  MISSING: '$skill' not found in:$missing"
    errors=$((errors + 1))
  fi
done

if [ "$errors" -eq 0 ]; then
  echo "  All skills present in all 3 formats."
fi

# ── Gemini Frontmatter Check ─────────────────────────────────
echo ""
echo "Checking Gemini YAML frontmatter..."

for skill_dir in "$GEMINI_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    echo "  ERROR: $skill — missing SKILL.md"
    errors=$((errors + 1))
    continue
  fi

  # Check for frontmatter
  first_line=$(head -1 "$skill_file")
  if [ "$first_line" != "---" ]; then
    echo "  WARNING: $skill — missing YAML frontmatter (no --- header)"
    warnings=$((warnings + 1))
  fi
done

if [ "$warnings" -eq 0 ] && [ "$errors" -eq 0 ]; then
  echo "  All Gemini skills have YAML frontmatter."
fi

# ── Agents Check ──────────────────────────────────────────────
echo ""
echo "Checking agents..."

if [ -d "$AGENTS_DIR" ]; then
  agent_count=$(ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "  Found $agent_count agents"

  for agent in "$AGENTS_DIR"/*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent" .md)

    # Check for YAML frontmatter
    first_line=$(head -1 "$agent")
    if [ "$first_line" != "---" ]; then
      echo "  WARNING: $name — missing YAML frontmatter"
      warnings=$((warnings + 1))
    fi
  done
else
  echo "  No agents directory found"
fi

# ── Hooks Check ───────────────────────────────────────────────
echo ""
echo "Checking hooks..."

if [ -d "$HOOKS_DIR" ]; then
  hook_count=$(ls -1 "$HOOKS_DIR"/*.sh 2>/dev/null | wc -l | tr -d ' ')
  echo "  Found $hook_count hooks"

  for hook in "$HOOKS_DIR"/*.sh; do
    [ -f "$hook" ] || continue
    name=$(basename "$hook")

    # Check shebang
    first_line=$(head -1 "$hook")
    if [[ "$first_line" != "#!/bin/bash" && "$first_line" != "#!/usr/bin/env bash" ]]; then
      echo "  WARNING: $name — missing bash shebang"
      warnings=$((warnings + 1))
    fi

    # Check executable bit
    if [ ! -x "$hook" ]; then
      echo "  WARNING: $name — not executable (run: chmod +x hooks/$name)"
      warnings=$((warnings + 1))
    fi
  done
else
  echo "  No hooks directory found"
fi

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "─────────────────────────"
echo "Skills: $claude_count | Agents: ${agent_count:-0} | Hooks: ${hook_count:-0}"

if [ "$errors" -gt 0 ]; then
  echo "RESULT: $errors error(s), $warnings warning(s)"
  exit 1
elif [ "$warnings" -gt 0 ]; then
  echo "RESULT: $warnings warning(s), 0 errors"
  exit 0
else
  echo "RESULT: All checks passed"
  exit 0
fi
