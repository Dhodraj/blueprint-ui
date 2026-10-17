#!/usr/bin/env bash
# Runs every suite in this repo.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fail=0
for suite in "$here/../skills/blueprint/tests/run.sh" "$here/../plugin/tests/run.sh"; do
  printf '== %s\n' "${suite#$here/../}"
  bash "$suite" || fail=1
done
printf '\n== sources.json\n'
node "$here/../skills/blueprint/scripts/check-sources.js" "$here/../skills/blueprint/sources.json" || fail=1
(( fail == 0 )) && echo "ALL GREEN"
exit "$fail"
