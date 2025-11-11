#!/bin/bash
# massexec.sh [--path dirpath] [--mask mask] [--number number] command

set -euo pipefail

DIR="."
MASK="*"
NUM=""

# --- разбор аргументов ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      DIR="$2"
      shift 2
      ;;
    --mask)
      MASK="$2"
      shift 2
      ;;
    --number)
      NUM="$2"
      shift 2
      ;;
    *)
      # всё, дальше идёт команда
      CMD="$1"
      shift
      break
      ;;
  esac
done

# проверка, что команда есть
if [[ -z "${CMD:-}" ]]; then
  echo "Usage: $0 [--path dirpath] [--mask mask] [--number number] command" >&2
  exit 1
fi

# проверка каталога
if [[ ! -d "$DIR" ]]; then
  echo "Not a directory: $DIR" >&2
  exit 1
fi

# если number не задан — берём количество ядер CPU
if [[ -z "$NUM" ]]; then
  if command -v nproc >/dev/null 2>&1; then
    NUM="$(nproc)"
  elif [[ -r /proc/cpuinfo ]]; then
    NUM="$(grep -c '^processor' /proc/cpuinfo || echo 1)"
  else
    NUM="$(sysctl -n hw.ncpu 2>/dev/null || echo 1)"
  fi
fi

# проверка, что NUM — целое > 0
if ! [[ "$NUM" =~ ^[0-9]+$ ]] || [[ "$NUM" -le 0 ]]; then
  echo "--number must be positive integer" >&2
  exit 1
fi

# проверка mask
if [[ -z "$MASK" ]]; then
  echo "Mask must be non-empty" >&2
  exit 1
fi

# абсолютный путь к каталогу
DIR_ABS="$(cd "$DIR" && pwd)"

# список файлов по маске (в этом каталоге, без рекурсии)
shopt -s nullglob
FILES=( "$DIR_ABS"/$MASK )
shopt -u nullglob

# оставляем только обычные файлы
TMP=()
for f in "${FILES[@]}"; do
  if [[ -f "$f" ]]; then
    TMP+=( "$f" )
  fi
done
FILES=( "${TMP[@]}" )

# если файлов нет — выходим
if [[ ${#FILES[@]} -eq 0 ]]; then
  exit 0
fi

# массив PID-ов запущенных процессов
pids=()

# функция запуска одной задачи
start_job() {
  local file="$1"
  "$CMD" "$file" &
  pids+=( "$!" )
}

# основной цикл: не больше NUM процессов одновременно
for f in "${FILES[@]}"; do
  # если уже запущено NUM процессов — ждём завершения самого старого
  if [[ ${#pids[@]} -ge "$NUM" ]]; then
    wait "${pids[0]}"
    # удаляем первый PID из массива
    pids=( "${pids[@]:1}" )
  fi
  start_job "$f"
done

# ждём все оставшиеся процессы
for pid in "${pids[@]}"; do
  wait "$pid"
done
