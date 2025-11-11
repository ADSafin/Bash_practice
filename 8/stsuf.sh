#!/bin/bash
# stsuf DIR  → печатает статистику по суффиксам

set -euo pipefail

dir="${1:-}"
if [[ -z "$dir" ]]; then
  echo "Usage: $0 DIR" >&2
  exit 1
fi

if [[ ! -d "$dir" ]]; then
  echo "Not a directory: $dir" >&2
  exit 1
fi

declare -A cnt

get_suffix() {
  local name="$1"
  # если имя начинается с '.' и больше точек нет — суффикса нет
  if [[ "$name" == .* && "$name" != *.*.* ]]; then
    echo "no suffix"
    return
  fi

  if [[ "$name" == *.* ]]; then
    # суффикс — точка + хвост после последней точки
    echo ".${name##*.}"
  else
    echo "no suffix"
  fi
}

while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  suf="$(get_suffix "$base")"

  # инициализируем, если ещё нет такого ключа
  if [[ -z ${cnt["$suf"]+_} ]]; then
    cnt["$suf"]=0
  fi

  cnt["$suf"]=$(( cnt["$suf"] + 1 ))
done < <(find "$dir" -type f -print0)

# выводим отсортированно по убыванию количества
{
  for k in "${!cnt[@]}"; do
    printf "%s\t%d\n" "$k" "${cnt[$k]}"
  done
} | sort -t $'\t' -k2,2nr | while IFS=$'\t' read -r k v; do
  echo "$k: $v"
done
