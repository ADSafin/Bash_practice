#!/bin/bash
# Задача 1

set -u

RESET=$'\e[0m'
RED=$'\e[31m'
GREEN=$'\e[32m'

steps=0
hits=0
miss=0
declare -a last=()

print_stats() {
  total=$((hits + miss))
  if (( total == 0 )); then
    echo "Hit: 0% Miss: 0%"
  else
    hitp=$(awk "BEGIN {printf \"%.2f\", ($hits/$total)*100}")
    missp=$(awk "BEGIN {printf \"%.2f\", ($miss/$total)*100}")
    echo "Hit: ${hitp}% Miss: ${missp}%"
  fi

  echo -n "Numbers: "
  local start=0
  if (( ${#last[@]} > 10 )); then
    start=$((${#last[@]} - 10))
    last=("${last[@]:start}")
  fi
  for ((i=0; i < ${#last[@]}; i++)); do
    printf "%s " "${last[i]}"
  done
  echo
}

while true; do
  steps=$((steps+1))
  secret=$(( RANDOM % 10 ))

  echo -n "Step: ${steps}
Please enter number from 0 to 9 (q - quit): "
  IFS= read -r inp || exit 0
  [[ $inp == "q" ]] && exit 0

  if [[ -z "$inp" ]]; then
    echo "Input is empty. Try again."
    steps=$((steps-1))
    continue
  fi

  if [[ ! $inp =~ ^[0-9]$ ]]; then
    echo "Invalid input. Try again."
    steps=$((steps-1))
    continue
  fi

  if (( inp == secret )); then
    echo "Hit! My number: $secret"
    hits=$((hits+1))
    last+=( "${GREEN}${secret}${RESET}" )
  else
    echo "Miss! My number: $secret"
    miss=$((miss+1))
    last+=( "${RED}${secret}${RESET}" )
  fi

  print_stats
done
