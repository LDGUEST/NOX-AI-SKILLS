#!/bin/bash
# nox-parse.sh — Compatibility wrapper for lib-json.sh
# Legacy hooks may source this file. Delegates to lib-json.sh.
#
# Usage: source nox-parse.sh; val=$(nox_field "key" "$INPUT")

source "$(dirname "${BASH_SOURCE[0]}")/lib-json.sh"

# When run directly (not sourced), respect NOX_SKIP_ALL
[[ "${BASH_SOURCE[0]}" == "$0" ]] && [ "${NOX_SKIP_ALL:-0}" = "1" ] && exit 0

nox_field() {
    # $1 = key, $2 = JSON string (note: reversed arg order from json_str)
    json_str "$2" "$1"
}

nox_nested() {
    # For nested fields, fall back to python3
    local path="$1" input="$2"
    python3 -c "
import sys,json
d=json.loads(sys.stdin.read())
keys='${path}'.split('.')
for k in keys:
    if isinstance(d,dict):
        d=d.get(k,'')
    else:
        d=''
        break
print(d)
" <<< "$input" 2>/dev/null
}
