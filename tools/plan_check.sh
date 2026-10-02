#!/usr/bin/env bash
# plan_check.sh -- compile the corpus with --plan-check and count the calls
# codegen emitted through a builtin-op row that inference did not answer
# with (#7100).
#
#   tools/plan_check.sh [-v]
#
# A "conflict" (inference answered the call from a different row of the
# same receiver kind) fails: the two halves of the compiler decided the
# call differently. An "unrecorded" call (inference answered without a
# row) and a "respecialized" one (the node is emitted per copy with its
# receiver typed per copy) are reported as counts; -v lists all three.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
SP=$ROOT/bin/spinel
[ -x "$SP" ] || { echo "plan-check: build bin/spinel first" >&2; exit 2; }
JOBS=${PLAN_CHECK_JOBS:-$(nproc)}
OUT=$(mktemp "${TMPDIR:-/tmp}/spinel-plan-check.XXXXXX")
PARTS=$(mktemp -d "${TMPDIR:-/tmp}/spinel-plan-check-parts.XXXXXX")
# one file per program: the parallel jobs' lines must not interleave
{ ls test/*.rb benchmark/*.rb packages/*/test/*.rb 2>/dev/null
  [ -f build/optcarrot-single.rb ] && echo build/optcarrot-single.rb; } |
  xargs -P "$JOBS" -I{} sh -c '
    "$2" -c --no-line-map --plan-check "$1" -o /dev/null 2>&1 | grep "^plan-check:" | sed "s|^|$1: |" \
      > "$3/$(printf %s "$1" | tr / _)"
  ' _ {} "$SP" "$PARTS"
find "$PARTS" -type f -exec cat {} + > "$OUT"
rm -rf "$PARTS"
nc=$(grep -c ': plan-check: conflict:' "$OUT")
nu=$(grep -c ': plan-check: unrecorded:' "$OUT")
nr=$(grep -c ': plan-check: respecialized:' "$OUT")
uc=$(grep -c ': plan-check: ucall-conflict:' "$OUT")
ur=$(grep -c ': plan-check: ucall-respecialized:' "$OUT")
uv=$(grep -c ': plan-check: ucall-virtual:' "$OUT")
uu=$(grep -c ': plan-check: ucall-unrecorded:' "$OUT")
uo=$(grep -c ': plan-check: ucall-unobserved:' "$OUT")
ue=$(grep -c ': plan-check: ucall-unemitted:' "$OUT")
uf=$(grep -c ': plan-check: ucall-refused:' "$OUT")
[ "${1-}" = "-v" ] && cat "$OUT"
grep ': plan-check: conflict:' "$OUT" | head -20
grep ': plan-check: ucall-conflict:' "$OUT" | head -20
rm -f "$OUT"
echo "plan-check: $nc conflicts, $nu unrecorded, $nr respecialized"
echo "plan-check: user methods: $uc ucall-conflicts, $ur ucall-respecialized, $uv ucall-virtual, $uu ucall-unrecorded, $uo ucall-unobserved, $ue ucall-unemitted, $uf ucall-refused"
[ "$nc" -eq 0 ] && [ "$uc" -eq 0 ]
