#!/usr/bin/env bash
# nil_check.sh -- compile the corpus with --nil-check and count where the
# analysis's nil fact and today's helpers answer differently (#7444).
#
#   tools/nil_check.sh [-v]
#
# The compiler reports, per program (see nil_check_report, codegen_call.c,
# and vt_nil_witness_check, analyze.c):
#   recv   each call on an object receiver nil_recv_guard decided
#   ret    each method whose value is an object (method_ret_nilable)
#   local  each object local (local_obj_nil_written)
#   param  each object parameter (obj_nilable)
#   vt     each class the value-type selection considered (its nil witness)
# as AGREE, FACT-ONLY (the fact sees a nil the helper does not, with where
# the fact's nil comes from), HELPER-ONLY (the helper sees a nil the fact
# does not), GUARDED (the helper's nil at a read a guard proves is not
# nil, which the fact narrows) or INIT-SET (the helper's guard on an ivar
# only `||=` writes, which initialize sets). The counts are summed and the FACT-ONLY
# cases grouped. The run fails on a HELPER-ONLY, and when the C differs
# with the flag.
#
# NIL_CHECK_FLAGS adds compiler flags (e.g. --int-overflow=promote).
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
SP=$ROOT/bin/spinel
[ -x "$SP" ] || { echo "nil-check: build bin/spinel first" >&2; exit 2; }
JOBS=${NIL_CHECK_JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu)}
NIL_CHECK_FLAGS=${NIL_CHECK_FLAGS-}
export NIL_CHECK_FLAGS
OUT=$(mktemp "${TMPDIR:-/tmp}/spinel-nil-check.XXXXXX")
PARTS=$(mktemp -d "${TMPDIR:-/tmp}/spinel-nil-check-parts.XXXXXX")
# one file per program: the parallel jobs' lines must not interleave. Each
# program is compiled with and without the flag, and the two C files compared.
{ ls test/*.rb test/infer/*.rb benchmark/*.rb packages/*/test/*.rb 2>/dev/null
  [ -f build/optcarrot-single.rb ] && echo build/optcarrot-single.rb; } |
  xargs -P "$JOBS" -I{} sh -c '
    k=$(printf %s "$1" | tr / _)
    "$2" -c $NIL_CHECK_FLAGS --nil-check "$1" -o "$3/$k.on.c" 2>"$3/$k.err" >/dev/null
    "$2" -c $NIL_CHECK_FLAGS "$1" -o "$3/$k.off.c" >/dev/null 2>&1
    if [ -f "$3/$k.on.c" ] || [ -f "$3/$k.off.c" ]; then
      cmp -s "$3/$k.on.c" "$3/$k.off.c" || echo "$1" > "$3/$k.cdiff"
    fi
    grep "^nil-check:" "$3/$k.err" | sed "s|^|$1: |" > "$3/$k.log"
    rm -f "$3/$k.on.c" "$3/$k.off.c" "$3/$k.err"
  ' _ {} "$SP" "$PARTS"
find "$PARTS" -name '*.log' -type f -exec cat {} + > "$OUT"
ndiff=$(find "$PARTS" -name '*.cdiff' | wc -l | tr -d ' ')
find "$PARTS" -name '*.cdiff' -exec cat {} + | head -10
rm -rf "$PARTS"
[ "${1-}" = "-v" ] && grep -v ': nil-check: count ' "$OUT"
nhelper=0
for cat in recv ret local param vt; do
  sum=$(grep ": nil-check: count $cat " "$OUT" |
    awk '{ a += $6; f += $8; h += $10; g += $12; i += $14 } END { printf "%d %d %d %d %d", a, f, h, g, i }')
  set -- $sum
  echo "nil-check: $cat: $1 agree, $2 fact-only, $3 helper-only, $4 guarded, $5 init-set"
  nhelper=$((nhelper + $3))
done
echo "nil-check: FACT-ONLY by category, receiver kind and where the fact's nil comes from:"
grep ': nil-check: [a-z]* FACT-ONLY' "$OUT" |
  sed -E 's/.*: nil-check: recv FACT-ONLY ([a-z-]+)( by-value)?( nil-answers)? (why=[a-z-]+).*/recv \1\2\3 \4/;
          s/.*: nil-check: (ret|local|param) FACT-ONLY (why=[a-z-]+).*/\1 \2/;
          s/.*: nil-check: vt FACT-ONLY [^ ]+( by-value)? (why=[a-z-]+).*/vt\1 \2/' |
  sort | uniq -c | sort -rn | head -40
grep ': nil-check: [a-z]* HELPER-ONLY' "$OUT" | head -20
echo "nil-check: $ndiff programs whose C differs with the flag"
rm -f "$OUT"
[ "$ndiff" -eq 0 ] && [ "$nhelper" -eq 0 ]
