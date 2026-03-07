#!/usr/bin/env bash
set -eu
(set -o pipefail 2>/dev/null) && set -o pipefail

# Nox Uninstaller — removes all Nox skills, agents, and hooks
# Usage: bash uninstall.sh [--claude-only | --gemini-only | --codex-only | --hooks-too]

CLAUDE_DEST="$HOME/.claude/commands/nox"
GEMINI_DEST="$HOME/.gemini/extensions/nox"
CODEX_DEST="$HOME/.agents/skills"
AGENTS_DEST="$HOME/.claude/agents"
HOOKS_DEST="$HOME/.claude/hooks"

REMOVE_CLAUDE=true
REMOVE_GEMINI=true
REMOVE_CODEX=true
REMOVE_HOOKS=false

for arg in "$@"; do
  case "$arg" in
    --claude-only) REMOVE_GEMINI=false; REMOVE_CODEX=false ;;
    --gemini-only) REMOVE_CLAUDE=false; REMOVE_CODEX=false ;;
    --codex-only)  REMOVE_CLAUDE=false; REMOVE_GEMINI=false ;;
    --hooks-too)   REMOVE_HOOKS=true ;;
    --help|-h)
      echo "Nox Uninstaller"
      echo ""
      echo "Usage: bash uninstall.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --claude-only   Only remove Claude Code skills"
      echo "  --gemini-only   Only remove Gemini CLI skills"
      echo "  --codex-only    Only remove Codex CLI skills"
      echo "  --hooks-too     Also remove hooks (not removed by default)"
      echo "  --help          Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (try --help)"
      exit 1
      ;;
  esac
done

# ── Claude Code ──────────────────────────────────────────────
if [ "$REMOVE_CLAUDE" = true ]; then
  if [ -d "$CLAUDE_DEST" ]; then
    count=$(ls -1 "$CLAUDE_DEST"/*.md 2>/dev/null | wc -l | tr -d ' ')
    rm -rf "$CLAUDE_DEST"
    echo "Removed $count Claude Code skills from $CLAUDE_DEST/"
  else
    echo "No Claude Code skills found at $CLAUDE_DEST/"
  fi

  # Remove agents
  if [ -d "$AGENTS_DEST" ]; then
    agent_count=0
    for agent in "$AGENTS_DEST"/nox-*.md; do
      [ -f "$agent" ] || continue
      rm -f "$agent"
      agent_count=$((agent_count + 1))
    done
    if [ "$agent_count" -gt 0 ]; then
      echo "Removed $agent_count agents from $AGENTS_DEST/"
    fi
  fi
fi

# ── Gemini CLI ───────────────────────────────────────────────
if [ "$REMOVE_GEMINI" = true ]; then
  if [ -d "$GEMINI_DEST" ]; then
    count=$(find "$GEMINI_DEST/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    rm -rf "$GEMINI_DEST"
    echo "Removed $count Gemini CLI skills from $GEMINI_DEST/"
  else
    echo "No Gemini CLI skills found at $GEMINI_DEST/"
  fi
fi

# ── Codex CLI ────────────────────────────────────────────────
if [ "$REMOVE_CODEX" = true ]; then
  if [ -d "$CODEX_DEST" ]; then
    count=$(find "$CODEX_DEST" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    rm -rf "$CODEX_DEST"
    echo "Removed $count Codex CLI skills from $CODEX_DEST/"
  else
    echo "No Codex CLI skills found at $CODEX_DEST/"
  fi
fi

# ── Hooks ────────────────────────────────────────────────────
if [ "$REMOVE_HOOKS" = true ]; then
  if [ -d "$HOOKS_DEST" ]; then
    hook_count=0
    for hook in destructive-guard sync-guard secret-scanner debug-reminder build-tracker cost-alert notify-complete notify-timer-start commit-lint test-regression-guard file-size-guard todo-tracker drift-detector auto-context compact-saver session-logger agent-tracker prompt-guard memory-auto-save; do
      if [ -f "$HOOKS_DEST/$hook.sh" ]; then
        rm -f "$HOOKS_DEST/$hook.sh"
        hook_count=$((hook_count + 1))
      fi
    done
    if [ "$hook_count" -gt 0 ]; then
      echo "Removed $hook_count hooks from $HOOKS_DEST/"
      echo ""
      echo "NOTE: Hook entries in ~/.claude/settings.json were NOT removed."
      echo "Edit settings.json manually to remove hook references if desired."
    fi
  else
    echo "No hooks found at $HOOKS_DEST/"
  fi
else
  echo ""
  echo "Hooks were NOT removed (use --hooks-too to include them)."
fi

# ── MCP Server ──────────────────────────────────────────────────
MCP_JSON="$HOME/.claude/.mcp.json"
if [ -f "$MCP_JSON" ] && grep -q '"nox"' "$MCP_JSON" 2>/dev/null; then
  python3 -c "
import json
with open('$MCP_JSON', 'r') as f:
    data = json.load(f)
if 'mcpServers' in data and 'nox' in data['mcpServers']:
    del data['mcpServers']['nox']
    with open('$MCP_JSON', 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    print('Removed Nox MCP server from ' + '$MCP_JSON')
" 2>/dev/null || echo "Could not update $MCP_JSON — remove 'nox' entry manually"
fi

echo ""
echo "Nox uninstalled."
echo ""
echo "If you installed via curl (to ~/.nox), you can also remove the clone:"
echo "  rm -rf ~/.nox"
