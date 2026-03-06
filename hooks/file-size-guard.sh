#!/bin/bash
# Nox Hook: file-size-guard
# Event: PreToolUse (Write)
# Purpose: Blocks writing files over a size threshold — catches accidental base64 dumps, minified bundles, large JSON blobs
# Install: bash install.sh --with-hooks
# Config: NOX_SKIP_FILE_SIZE_GUARD=1 to disable
#         NOX_FILE_SIZE_LIMIT=512000 (bytes, default 500KB)
set -eu

[ "${NOX_SKIP_FILE_SIZE_GUARD:-0}" = "1" ] && exit 0

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# Only trigger on Write tool
[ "$TOOL" != "Write" ] && exit 0

LIMIT="${NOX_FILE_SIZE_LIMIT:-512000}"

# Get content size in bytes
SIZE=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
content=d.get('tool_input',{}).get('content','') or d.get('tool_input',{}).get('file_text','') or ''
print(len(content.encode('utf-8')))
" 2>/dev/null || echo "0")

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path','unknown'))" 2>/dev/null || echo "unknown")

if [ "$SIZE" -gt "$LIMIT" ] 2>/dev/null; then
    SIZE_KB=$((SIZE / 1024))
    LIMIT_KB=$((LIMIT / 1024))
    echo "BLOCKED: File write exceeds size limit (${SIZE_KB}KB > ${LIMIT_KB}KB)" >&2
    echo "  File: $FILE_PATH" >&2
    echo "  This often means minified code, base64 data, or large JSON is being written to source." >&2
    echo "  If intentional, set NOX_FILE_SIZE_LIMIT=$((SIZE + 1024)) or NOX_SKIP_FILE_SIZE_GUARD=1" >&2
    exit 2
fi

exit 0
