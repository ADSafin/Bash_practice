#!/bin/bash
# mkarch -d DIR -n NAME  → создаёт самораспаковывающийся скрипт NAME

set -eu

dir=""
name=""
while getopts ":d:n:" opt; do
  case "$opt" in
    d) dir="$OPTARG" ;;
    n) name="$OPTARG" ;;
    *) echo "Usage: $0 -d dir_path -n name" >&2; exit 1 ;;
  esac
done

[[ -n "$dir" && -n "$name" ]] || { echo "Both -d and -n are required." >&2; exit 1; }
[[ -d "$dir" ]] || { echo "No such directory: $dir" >&2; exit 1; }

# 1) Заголовок распаковщика
cat > "$name" <<'HDR'
#!/usr/bin/env bash
set -e
outdir="."
while getopts ":o:" opt; do
  case "$opt" in
    o) outdir="$OPTARG" ;;
  esac
done
mkdir -p "$outdir"

# пробуем разные декодеры base64 (GNU, BSD/macOS, openssl)
if awk '/^__ARCHIVE_BELOW__/ {found=1; next} found {print}' "$0" | base64 -d 2>/dev/null | tar -xz -C "$outdir" 2>/dev/null; then
  :
elif awk '/^__ARCHIVE_BELOW__/ {found=1; next} found {print}' "$0" | base64 -D 2>/dev/null | tar -xz -C "$outdir" 2>/dev/null; then
  :
else
  awk '/^__ARCHIVE_BELOW__/ {found=1; next} found {print}' "$0" | openssl base64 -d | tar -xz -C "$outdir"
fi
exit 0
__ARCHIVE_BELOW__
HDR

tar -C "$dir" -cz . | base64 >> "$name"

chmod +x "$name"

echo "Created: ./$name"
