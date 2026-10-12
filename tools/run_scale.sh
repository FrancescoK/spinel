#!/usr/bin/env bash
# run_scale.sh -- a run-time scaling check (#7501, item 4).
#
#   tools/run_scale.sh [SPINEL] [SHAPES...]
#
# `make scale-test` checks that the compiler's work grows linearly; this
# checks the programs it makes. Each shape under test/run_scale/ names two
# argument lists and the largest ratio of the bytes it may allocate between
# them, on its first line:
#
#   # run-scale: SMALL ARGS | LARGE ARGS | MAX RATIO
#
# The shape is compiled once and run with each, under SPINEL_ALLOC_REPORT
# (lib/sp_alloc.c); the run fails when the large run's bytes over the small
# run's pass the ratio, or when the two runs end otherwise than both with 0.
# #7482's program is the first shape: its bytes must not grow with the
# number of calls. One line per shape, and the failures again at the end.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SP=${1:-$ROOT/bin/spinel}
[ $# -gt 0 ] && shift
[ -x "$SP" ] || { echo "run-scale: build bin/spinel first" >&2; exit 2; }
SHAPES=("$@")
[ ${#SHAPES[@]} -gt 0 ] || SHAPES=("$ROOT"/test/run_scale/*.rb)
T=$(mktemp -d "${TMPDIR:-/tmp}/spinel-run-scale.XXXXXX") || exit 2
trap 'rm -rf "$T"' EXIT
fail=0; failed=
bytes() { awk '/^# bytes /{b+=$NF} END {print b+0}' "$1"; }
for p in "${SHAPES[@]}"; do
  n=$(basename "$p" .rb)
  spec=$(sed -n '1s/^# run-scale: *//p' "$p")
  [ -n "$spec" ] || { echo "run-scale: $n has no '# run-scale:' line" >&2; fail=1; continue; }
  small=$(echo "$spec" | cut -d'|' -f1); large=$(echo "$spec" | cut -d'|' -f2); max=$(echo "$spec" | cut -d'|' -f3 | tr -d ' ')
  if ! "$SP" "$p" -o "$T/$n" > "$T/$n.cc" 2>&1; then
    echo "run-scale: $n FAIL (does not compile)"; fail=1; failed="$failed $n"; continue
  fi
  SPINEL_ALLOC_REPORT="$T/$n.s" "$T/$n" $small > /dev/null 2>&1; rs=$?
  SPINEL_ALLOC_REPORT="$T/$n.l" "$T/$n" $large > /dev/null 2>&1; rl=$?
  if [ $rs != 0 ] || [ $rl != 0 ] || [ ! -f "$T/$n.s" ] || [ ! -f "$T/$n.l" ]; then
    echo "run-scale: $n FAIL (exit $rs / $rl)"; fail=1; failed="$failed $n"; continue
  fi
  bs=$(bytes "$T/$n.s"); bl=$(bytes "$T/$n.l")
  verdict=$(awk -v s="$bs" -v l="$bl" -v m="$max" 'BEGIN { r = s > 0 ? l / s : (l > 0 ? 1e9 : 1); printf "%.2f %s", r, r <= m ? "ok" : "FAIL" }')
  echo "run-scale: $n bytes $bs -> $bl, ratio ${verdict% *} (limit $max) ${verdict#* }"
  case $verdict in *FAIL) fail=1; failed="$failed $n";; esac
done
[ $fail = 0 ] && echo "run-scale: all ${#SHAPES[@]} shapes within their limits" || echo "run-scale: FAILED:$failed"
exit $fail
