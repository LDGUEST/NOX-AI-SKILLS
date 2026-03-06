#!/bin/bash
# Nox Hook: branch-protect
# Event: PreToolUse (Bash)
# Purpose: Blocks direct commits and pushes to main/master — forces feature branches
# Install: bash install.sh --with-hooks
# Config: NOX_SKIP_BRANCH_PROTECT=1 to disable
#         NOX_PROTECTED_BRANCHES="main|master|production" to customize
set -eu

[ "${NOX_SKIP_BRANCH_PROTECT:-0}" = "1" ] && exit 0

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")
[ "$TOOL" != "Bash" ] && exit 0

CMD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")
[ -z "$CMD" ] && exit 0

# Only care about git commit and git push
echo "$CMD" | grep -qE "git (commit|push)" || exit 0

# Check if we're in a git repo
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -z "$BRANCH" ] && exit 0

PROTECTED="${NOX_PROTECTED_BRANCHES:-main|master|production}"

if echo "$BRANCH" | grep -qE "^($PROTECTED)$"; then
    # Allow push to non-protected remote branches (e.g. git push origin feature/x)
    if echo "$CMD" | grep -qE "git push .+ [^ ]+" ; then
        PUSH_BRANCH=$(echo "$CMD" | grep -oE "git push [^ ]+ ([^ ]+)" | awk '{print $NF}')
        if [ -n "$PUSH_BRANCH" ] && ! echo "$PUSH_BRANCH" | grep -qE "^($PROTECTED)$"; then
            exit 0
        fi
    fi

    if echo "$CMD" | grep -q "git commit"; then
        echo "BLOCKED: Direct commit to '$BRANCH'. Create a feature branch first:" >&2
        echo "  git checkout -b feat/your-change" >&2
        echo "  (or set NOX_SKIP_BRANCH_PROTECT=1 to override)" >&2
        exit 2
    fi

    if echo "$CMD" | grep -q "git push"; then
        echo "BLOCKED: Direct push to '$BRANCH'. Push to a feature branch and create a PR:" >&2
        echo "  git push origin feat/your-change" >&2
        echo "  (or set NOX_SKIP_BRANCH_PROTECT=1 to override)" >&2
        exit 2
    fi
fi

exit 0
