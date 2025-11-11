#!/bin/bash
# addline DIR  → prepend "Approved USER DATE" каждой .txt (без рекурсии)

set -euo pipefail
dir="${1:-}"
[[ -n "$dir" ]] || { echo "Usage: $0 DIR"; exit 1; }
[[ -d "$dir" ]] || { echo "Not a directory: $dir"; exit 1; }

user="${USER:-$(whoami)}"
# ISO-8601: локальное время (кросс-платформенный формат)
date_iso="$(date +"%Y-%m-%dT%H:%M:%S%z")"

shopt -s nullglob
for f in "$dir"/*.txt; do
  [[ -f "$f" ]] || continue
  tmp="$(mktemp)"
  {
    echo "Approved $user $date_iso"
    cat "$f"
  } > "$tmp"
  mv "$tmp" "$f"
  echo "Updated: $f"
done
shopt -u nullglob
