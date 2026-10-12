#!/usr/bin/env bash
# arm_check.sh -- compile the corpus with --arm-check and count where the
# per-arm facts (#7483, analyze_arm.c) and codegen's per-arm typing of a
# block body (arm_body_infer, codegen_view.c) disagree.
#
#   tools/arm_check.sh [-v]
#
# The compiler prints
#   MISSING   codegen typed a block body under a parameter type the
#             analysis recorded no fact for
#   MISMATCH  a node of the body that codegen typed otherwise than the fact
# The run fails on either, and when the C differs with the flag.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
SP=$ROOT/bin/spinel
[ -x "$SP" ] || { echo "arm-check: build bin/spinel first" >&2; exit 2; }
JOBS=${ARM_CHECK_JOBS:-$(nproc)}
OUT=$(mktemp "${TMPDIR:-/tmp}/spinel-arm-check.XXXXXX")
PARTS=$(mktemp -d "${TMPDIR:-/tmp}/spinel-arm-check-parts.XXXXXX")
{ ls test/*.rb benchmark/*.rb packages/*/test/*.rb 2>/dev/null
  [ -f build/optcarrot-single.rb ] && echo build/optcarrot-single.rb; } |
  xargs -P "$JOBS" -I{} sh -c '
    k=$(printf %s "$1" | tr / _)
    "$2" -c --no-line-map --arm-check "$1" -o "$3/$k.on.c" 2>"$3/$k.err" >/dev/null
    "$2" -c --no-line-map "$1" -o "$3/$k.off.c" >/dev/null 2>&1
    if [ -f "$3/$k.on.c" ] || [ -f "$3/$k.off.c" ]; then
      cmp -s "$3/$k.on.c" "$3/$k.off.c" || echo "$1" > "$3/$k.cdiff"
    fi
    grep "^arm-check:" "$3/$k.err" | sed "s|^|$1: |" > "$3/$k.log"
    rm -f "$3/$k.on.c" "$3/$k.off.c" "$3/$k.err"
  ' _ {} "$SP" "$PARTS"
find "$PARTS" -name '*.log' -type f -exec cat {} + > "$OUT"
ndiff=$(find "$PARTS" -name '*.cdiff' | wc -l)
find "$PARTS" -name '*.cdiff' -exec cat {} + | head -10
rm -rf "$PARTS"
[ "${1-}" = "-v" ] && cat "$OUT"
nm=$(grep -c ': arm-check: MISSING' "$OUT"); nx=$(grep -c ': arm-check: MISMATCH' "$OUT")
grep ': arm-check: ' "$OUT" | head -10
echo "arm-check: $nm missing, $nx mismatches, $ndiff programs whose C differs with the flag"
rm -f "$OUT"
[ "$nm" = 0 ] && [ "$nx" = 0 ] && [ "$ndiff" = 0 ]
