#!/bin/bash
# Designed to be executed via svg-term from the smart-bash-history root directory:
# svg-term --command="bash doc/screencast.sh" --out doc/screencast.svg --padding=10
set -e
set -u

PROMPT="▶"

enter() {
    INPUT=$1
    DELAY=1

    prompt
    sleep "$DELAY"
    type "$INPUT"
    sleep 0.5
    printf '%b' "\\n"
    eval "$INPUT"
    printf '%b' "\\n"
}

prompt() {
  printf '%b ' $PROMPT | pv -q
}

type() {
    printf '%b' "$1" | pv -qL $((10+(-2 + RANDOM%5)))
}

main() {
    IFS='%'

    enter "smart-find"

    enter "git status"

    prompt

    sleep 3

    echo ""

    unset IFS
}

main
