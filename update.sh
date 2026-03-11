#!/usr/bin/env bash
set -euo pipefail

# NOX AI Skills — Self-updater
# Usage: bash update.sh
# Can also be triggered via /nox:update from any supported CLI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  Checking for NOX updates..."
echo ""

cd "$SCRIPT_DIR"

# Check for dirty working tree
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "  WARNING: You have uncommitted changes in $SCRIPT_DIR"
    echo "  Stashing changes before update..."
    git stash push -m "nox-update-$(date +%Y%m%d-%H%M%S)" --quiet
    STASHED=true
else
    STASHED=false
fi

# Get current state
LOCAL_HASH=$(git rev-parse --short HEAD)
LOCAL_DATE=$(git log -1 --format='%ci' HEAD | cut -d' ' -f1)

# Fetch latest
git fetch origin main --quiet 2>/dev/null || {
    echo "  ERROR: Could not reach GitHub. Check your connection."
    exit 1
}

REMOTE_HASH=$(git rev-parse --short origin/main)

if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
    echo "  Already up to date ($LOCAL_HASH, $LOCAL_DATE)"
    [ "$STASHED" = true ] && git stash pop --quiet
    exit 0
fi

# Show what's new
COMMIT_COUNT=$(git rev-list --count HEAD..origin/main)
echo "  Installed: $LOCAL_HASH ($LOCAL_DATE)"
echo "  Latest:    $REMOTE_HASH"
echo ""
echo "  What's New ($COMMIT_COUNT commits)"
echo "  ────────────────────────────────"
git log --oneline HEAD..origin/main | sed 's/^/  /'
echo ""

# Pull
echo "  Pulling..."
git pull origin main --quiet || {
    echo "  ERROR: git pull failed. Resolve conflicts manually."
    [ "$STASHED" = true ] && echo "  NOTE: Your changes are stashed. Run: git stash pop"
    exit 1
}

NEW_HASH=$(git rev-parse --short HEAD)

# Detect install mode
if [ -L "$HOME/.claude/commands/nox/update.md" ] 2>/dev/null || \
   [ -L "$HOME/.gemini/extensions/nox/gemini-extension.json" ] 2>/dev/null || \
   [ -L "$HOME/.codex/skills/commit/SKILL.md" ] 2>/dev/null; then
    echo "  Symlink mode — skills already updated via pull."
else
    echo "  Reinstalling skills..."
    bash "$SCRIPT_DIR/install.sh"
fi

# Restore stashed changes
[ "$STASHED" = true ] && git stash pop --quiet && echo "  Restored your local changes."

echo ""
echo "  NOX Updated: $LOCAL_HASH -> $NEW_HASH"
echo "  Restart your CLI session to pick up new skills."
echo ""
