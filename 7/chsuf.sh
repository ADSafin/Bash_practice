#!/bin/bash
# chsuf DIR OLD_SUFFIX NEW_SUFFIX
# пример: chsuf /data ".txt" ".md"

set -euo pipefail

dir="${1:-}"; old="${2:-}"; new="${3:-}"

[[ -n "$dir" && -n "$old" && -n "$new" ]] || { echo "Usage: $0 DIR OLD_SUFFIX NEW_SUFFIX"; exit 1; }
[[ -d "$dir" ]] || { echo "Not a directory: $dir"; exit 1; }

# суффикс: начинается с точki и не содержит других точек
valid_suf() { [[ "$1" =~ ^\.[^.]+$ ]]; }
valid_suf "$old" && valid_suf "$new" || { echo "Bad suffix format. Need like .txt"; exit 1; }

# идём по обычным файлам
while IFS= read -r -d '' p; do
  name="$(basename "$p")"
  dirn="$(dirname "$p")"
  # если имя начинается на '.' и больше точек нет — суффикса нет
  if [[ "$name" == .* && "$name" != *.*.* ]]; then
    continue
  fi
  # переименовываем только если имя оканчивается на $old
  if [[ "$name" == *"$old" ]]; then
    newname="${name/%$old/$new}"   # раскрытие параметра с заменой на конце
    if [[ "$newname" != "$name" ]]; then
      mv "$p" "$dirn/$newname"
      echo "$p -> $dirn/$newname"
    fi
  fi
done < <(find "$dir" -type f -print0)
