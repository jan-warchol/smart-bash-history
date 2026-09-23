#!/usr/bin/env bash
set -eo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)

set +e
pgrep -bash >/tmp/sbh-pgrep.out 2>/tmp/sbh-pgrep.err
red=$?
set -e
if [ "$red" -eq 0 ]; then
  echo "pgrep -bash unexpectedly succeeded" >&2
  exit 1
fi
grep -q "illegal option" /tmp/sbh-pgrep.err

hist=$(mktemp)
out=$(HISTFILE="$hist" /bin/bash -c 'source "$1"; printf "BASE %s\n" "$(__shell_basename "-bash")"; printf "BASE %s\n" "$(__shell_basename "/bin/bash")"; printf "SELF %s\n" "$$"; printf "%s\n" "$active_shells"' _ "$root/synchronization.sh")
printf '%s\n' "$out" | grep -q "^BASE bash$"
self=$(printf '%s\n' "$out" | awk '/^SELF / { print $2 }')
printf '%s\n' "$out" | grep -q "^${self}$"
if printf '%s\n' "$out" | grep -q "illegal option"; then
  echo "sourced script still hit pgrep -b" >&2
  exit 1
fi
echo "smart-bash-history darwin ok (pgrep -bash exit $red, bash pid $self listed)"
