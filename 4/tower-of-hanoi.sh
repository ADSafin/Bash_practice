#!/bin/bash
# 4 задание

set -u
trap 'echo; echo "Чтобы выйти, введите q или Q."; ' INT

A=(8 7 6 5 4 3 2 1)
B=()
C=()
step=1

print_stacks() {
  for ((h=7; h>=0; h--)); do
    printf "|%s|  |%s|  |%s|\n" \
      "$( (( ${#A[@]} > h )) && echo "${A[${#A[@]}-1-h]}" )" \
      "$( (( ${#B[@]} > h )) && echo "${B[${#B[@]}-1-h]}" )" \
      "$( (( ${#C[@]} > h )) && echo "${C[${#C[@]}-1-h]}" )"
  done
  echo "+-+  +-+  +-+"
  echo " A    B    C"
  echo
}

get_ref() {
  case "$1" in
    a) echo A ;;
    b) echo B ;;
    c) echo C ;;
    *) echo "" ;;
  esac
}

valid_move() {
  local -n from="$1" to="$2"
  (( ${#from[@]} > 0 )) || return 1
  local disk="${from[-1]}"
  if (( ${#to[@]} == 0 )); then return 0; fi
  (( disk < ${to[-1]} ))
}

is_win() {
  local want=(8 7 6 5 4 3 2 1)
  [[ "${B[*]-}" == "${want[*]}" ]] || [[ "${C[*]-}" == "${want[*]}" ]]
}

while :; do
  print_stacks
  printf "Ход № %d (откуда, куда): " "$step"
  IFS= read -r line || exit 1
  line="$(echo "$line" | tr -d ' ' | tr '[:upper:]' '[:lower:]')"
  case "$line" in
    q) exit 1 ;;
    ??) ;;
    *) echo "Ошибка ввода."; continue ;;
  esac
  src="${line:0:1}"; dst="${line:1:1}"
  srcv=$(get_ref "$src"); dstv=$(get_ref "$dst")
  if [[ -z $srcv || -z $dstv || $srcv == $dstv ]]; then
    echo "Ошибка ввода."; continue
  fi

  declare -n FROM="$srcv" TO="$dstv"
  if valid_move FROM TO; then
    disk="${FROM[-1]}"
    unset 'FROM[-1]'
    TO+=( "$disk" )
    if is_win; then
      print_stacks
      echo "Победа!"
      exit 0
    fi
    step=$((step+1))
  else
    echo "Такое перемещение запрещено!"
  fi
done
