#!/bin/bash
# 3 задание

set -u

board=()          # 16 чисел: 1..15 и 0 как пустая
steps=0

print_board() {
  echo "Ход № $steps"
  echo
  echo "+-------------------+"
  for r in 0 1 2 3; do
    printf "|"
    for c in 0 1 2 3; do
      idx=$((r*4+c))
      v=${board[idx]}
      if [[ $v -eq 0 ]]; then
        printf "    |"
      else
        printf " %2d |" "$v"
      fi
    done
    echo
    [[ $r -lt 3 ]] && echo "|-------------------|"
  done
  echo "+-------------------+"
  echo
}

# Сформируем заведомо решаемую позицию:
# из "собранного" состояния сделаем N случайных допустимых ходов
shuffle_board() {
  board=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0)
  local n=100 i
  for ((i=0;i<n;i++)); do
    # найдём индекс пустой
    local z
    for ((z=0;z<16;z++)); do [[ ${board[z]} -eq 0 ]] && break; done
    local zr=$((z/4)) zc=$((z%4))
    local moves=()
    ((zr>0)) && moves+=( $((z-4)) )
    ((zr<3)) && moves+=( $((z+4)) )
    ((zc>0)) && moves+=( $((z-1)) )
    ((zc<3)) && moves+=( $((z+1)) )
    local pick=${moves[RANDOM % ${#moves[@]}]}
    board[z]=${board[pick]}
    board[pick]=0
  done
}

can_move() {
  local num="$1" i z
  for ((i=0;i<16;i++)); do [[ ${board[i]} -eq $num ]] && break; done
  for ((z=0;z<16;z++)); do [[ ${board[z]} -eq 0 ]] && break; done
  local ir=$((i/4)) ic=$((i%4)) zr=$((z/4)) zc=$((z%4))
  # сосед по вертикали/горизонтали
  if { [[ $ir -eq $zr ]] && (( ${ic}==${zc}+1 || ${ic}+1==${zc} )); } ||
     { [[ $ic -eq $zc ]] && (( ${ir}==${zr}+1 || ${ir}+1==${zr}  )); }; then
     return 0
  fi
  return 1
}

do_move() {
  local num="$1" i z
  for ((i=0;i<16;i++)); do [[ ${board[i]} -eq $num ]] && break; done
  for ((z=0;z<16;z++)); do [[ ${board[z]} -eq 0 ]] && break; done
  board[z]=$num
  board[i]=0
}

neighbors_text() {
  local z
  for ((z=0;z<16;z++)); do [[ ${board[z]} -eq 0 ]] && break; done
  local zr=$((z/4)) zc=$((z%4)) m=()
  ((zr>0)) && m+=( ${board[z-4]} )
  ((zr<3)) && m+=( ${board[z+4]} )
  ((zc>0)) && m+=( ${board[z-1]} )
  ((zc<3)) && m+=( ${board[z+1]} )
  local IFS=', '
  echo "${m[*]}"
}

is_win() {
  for i in {0..14}; do
    [[ ${board[i]} -ne $((i+1)) ]] && return 1
  done
  [[ ${board[15]} -eq 0 ]]
}

shuffle_board
while :; do
  print_board
  printf "Ваш ход (q - выход): "
  IFS= read -r x || exit 0
  [[ $x == q ]] && exit 0
  if [[ ! $x =~ ^[0-9]+$ ]] || [[ $x -lt 1 || $x -gt 15 ]]; then
    echo "Неверный ввод."
    continue
  fi
  if can_move "$x"; then
    steps=$((steps+1))
    do_move "$x"
    if is_win; then
      echo "Вы собрали головоломку за ${steps} ходов."
      print_board
      exit 0
    fi
  else
    echo
    echo "Неверный ход!"
    echo "Невозможно костяшку $x передвинуть на пустую ячейку."
    echo -n "Можно выбрать: "
    echo "$(neighbors_text)"
    echo
  fi
done
