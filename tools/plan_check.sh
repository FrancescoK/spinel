#!/usr/bin/env bash
# plan_check.sh -- compile the corpus with --plan-check and count the calls
# codegen emitted through a builtin-op row that inference did not answer
# with (#7100).
#
#   tools/plan_check.sh [--from-results DIR] [-v]
#
# --from-results DIR: the gate's corpus leg compiled its programs with
# --plan-check already and left each one's report in DIR/<test>.plan
# (Makefile, TEST_PLAN_CHECK); those reports are read, and only the
# programs none of them covers (benchmarks, test/reject, test/collect, a
# test the corpus skips on this host) are compiled here.
#
# A "conflict" (inference answered the call from a different row of the
# same receiver kind) fails: the two halves of the compiler decided the
# call differently. An "unrecorded" call (inference answered without a
# row) and a "respecialized" one (the node is emitted per copy with its
# receiver typed per copy, compared with its own copy's row) fail too, as
# does a user call respecialized against its copy's method: all three were
# brought to 0 over the corpus (#9821, #9830), and a new one is fixed in its
# row, not counted. A poly dispatch's missing and extra arms (#9866) fail
# the same way. -v lists every kind; the counts that are not 0 yet
# (ucall-unrecorded) are reported, and join the failing set when they are.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
FROM=""
if [ "${1-}" = "--from-results" ]; then FROM=${2-}; shift 2 || exit 2; fi
SP=$ROOT/bin/spinel
[ -x "$SP" ] || { echo "plan-check: build bin/spinel first" >&2; exit 2; }
JOBS=${PLAN_CHECK_JOBS:-$(nproc)}
OUT=$(mktemp "${TMPDIR:-/tmp}/spinel-plan-check.XXXXXX")
PARTS=$(mktemp -d "${TMPDIR:-/tmp}/spinel-plan-check-parts.XXXXXX")
# one file per program: the parallel jobs' lines must not interleave. The
# refused programs (test/reject, test/collect) are compiled too, for the
# refusal shadow (refuse-*)
# with --from-results, the reports the corpus leg wrote, and the programs
# they name left out of the list
if [ -n "$FROM" ]; then find "$FROM" -name "*.plan" -type f -exec cat {} + > "$PARTS/_results"; fi
{ ls test/*.rb benchmark/*.rb packages/*/test/*.rb test/reject/*.rb test/collect/*.rb 2>/dev/null
  [ -f build/optcarrot-single.rb ] && echo build/optcarrot-single.rb; } |
  if [ -s "$PARTS/_results" ]; then awk -F": " 'NR == FNR { done[$1] = 1; next } !($0 in done)' "$PARTS/_results" -; else cat; fi |
  xargs -P "$JOBS" -I{} sh -c '
    # the compiler runs outside the pipe, so its exit status is kept: a
    # program that fails after it reported some diagnostics is no clean one
    out=$("$2" -c --no-line-map --plan-check "$1" -o /dev/null 2>&1); rc=$?
    { printf "%s\n" "$out" | grep "^plan-check:" | sed "s|^|$1: |"
      [ "$rc" -eq 0 ] || echo "$1: plan-check-exit: $rc"; } > "$3/$(printf %s "$1" | tr / _)"
  ' _ {} "$SP" "$PARTS"
find "$PARTS" -type f -exec cat {} + > "$OUT"
rm -rf "$PARTS"
nc=$(grep -c ': plan-check: conflict:' "$OUT")
nu=$(grep -c ': plan-check: unrecorded:' "$OUT")
nr=$(grep -c ': plan-check: respecialized:' "$OUT")
cv=$(grep -c ': plan-check: conversion-conflict:' "$OUT")
cva=$(grep -c ': plan-check: conversion-agree:' "$OUT")
uc=$(grep -c ': plan-check: ucall-conflict:' "$OUT")
ur=$(grep -c ': plan-check: ucall-respecialized:' "$OUT")
uv=$(grep -c ': plan-check: ucall-virtual:' "$OUT")
uu=$(grep -c ': plan-check: ucall-unrecorded:' "$OUT")
uo=$(grep -c ': plan-check: ucall-unobserved:' "$OUT")
ue=$(grep -c ': plan-check: ucall-unemitted:' "$OUT")
uf=$(grep -c ': plan-check: ucall-refused:' "$OUT")
ud=$(grep -c ': plan-check: ucall-dynamic:' "$OUT")
# codegen sites that read the plan: a plan naming another method than the
# site's own lookup is a conflict; a plan that cannot serve the site falls back
pc=$(grep -c ': plan-check: cplan-conflict:' "$OUT")
pm=$(grep -c ': plan-check: cplan-missing:' "$OUT")
pf=$(grep -c ': plan-check: cplan-fallback:' "$OUT")
# the resolver's per-program counts, summed
rsum=$(grep ': plan-check: ucall-resolver: ' "$OUT" | sed 's/.*ucall-resolver: //' |
  awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^[0-9]+$/) s[i] += $i }
       END { printf "codegen %d agree %d differ %d respecialized %d none; inference %d agree %d differ %d none",
             s[2], s[4], s[6], s[8], s[11], s[13], s[15] }')
[ "${1-}" = "-v" ] && cat "$OUT"
grep ': plan-check: conflict:' "$OUT" | head -20
grep ': plan-check: ucall-conflict:' "$OUT" | head -20
grep ': plan-check: cplan-conflict:' "$OUT" | head -20
grep ': plan-check: cplan-missing:' "$OUT" | head -20
grep ': plan-check: unrecorded:' "$OUT" | head -20
grep ': plan-check: respecialized:' "$OUT" | head -20
grep ': plan-check: ucall-respecialized:' "$OUT" | head -20
echo "plan-check: $nc conflicts, $nu unrecorded, $nr respecialized"
echo "plan-check: resolver: $rsum"
echo "plan-check: plan readers: $pc conflicts, $pf fallbacks, $pm cplan-missing"
# per site: the calls each took from the plan, and the ones it fell back on
for site in $(grep -E ': plan-check: cplan-(served|fallback|conflict|missing): ' "$OUT" | awk '{print $4}' | sort -u); do
  sv=$(grep ": plan-check: cplan-served: $site " "$OUT" | awk '{ s += $5 } END { print s + 0 }')
  fb=$(grep -c ": plan-check: cplan-fallback: $site " "$OUT")
  cf=$(grep -c ": plan-check: cplan-conflict: $site " "$OUT")
  ms=$(grep -c ": plan-check: cplan-missing: $site " "$OUT")
  echo "plan-check:   $site: $sv served, $fb fallbacks, $cf conflicts, $ms missing"
done
echo "plan-check: conversions: $cva agree, $cv conflicts"
echo "plan-check: user methods: $uc ucall-conflicts, $ur ucall-respecialized, $uv ucall-virtual, $uu ucall-unrecorded, $uo ucall-unobserved, $ue ucall-unemitted, $uf ucall-refused, $ud ucall-dynamic"
# poly dispatch arms: the switch codegen wrote against the resolver's arms
psum=$(grep ': plan-check: poly-arms: ' "$OUT" | sed 's/.*poly-arms: //' |
  awk '{ s += $1; a += $3; x += $5; m += $7; e += $9; k += $11; d += $14 }
       END { printf "%d switches, %d arms, %d poly-conflicts, %d poly-missing, %d poly-extra; trials %d kept, %d dropped",
             s, a, x, m, e, k, d }')
grep ': plan-check: poly-conflict:' "$OUT" | head -20
echo "plan-check: poly arms: $psum"
ppc=$(grep -c ': plan-check: poly-conflict:' "$OUT")
# the arms the plan has and the switch lacks (poly-missing), and the reverse
# (poly-extra): both 0 over the corpus since #9866, so either fails
ppm=$(grep -c ': plan-check: poly-missing:' "$OUT")
ppe=$(grep -c ': plan-check: poly-extra:' "$OUT")
grep ': plan-check: poly-missing:' "$OUT" | head -20
grep ': plan-check: poly-extra:' "$OUT" | head -20
# refusals: the ones codegen reports against the plan's (CP_REFUSE); the
# ones only codegen decides are counted by what is left (codegen_util.c)
rfsum=$(grep ': plan-check: refuse: ' "$OUT" | sed 's/.*refuse: //' | tr -d '(),' |
  awk '{ ok += $1; w += $3; cg += $5; a += $7; s += $9; n += $11; sc += $13; f += $15; u += $17 }
       END { printf "%d refuse-ok, %d refuse-wrong, %d refuse-codegen (%d call, %d shape, %d nomethod, %d string-copy, %d feature), %d refuse-unreached",
             ok, w, cg, a, s, n, sc, f, u }')
grep ': plan-check: refuse-wrong:' "$OUT" | head -20
echo "plan-check: refusals: $rfsum"
rfw=$(grep -c ': plan-check: refuse-wrong:' "$OUT")
# the iterator rows: well formed, no overlapping keys, no stale hand row (builtin_ops.c iter_rows_check)
irc=$(grep -c ': plan-check: iter-row-error:' "$OUT")
grep ': plan-check: iter-row-error:' "$OUT" | head -20
echo "plan-check: iterator rows: $irc errors"
# The programs listed here each pin a row flagged BOPF_INFERRED (inference
# types the call in a rule of its own, so it records no row). Beside the
# corpus-wide unrecorded count above, a listed program must also compile:
# one that stops compiling would drop out of that count instead of failing.
#   test/rational_round_inferred_plan.rb: Rational#round, #truncate, #floor and
#   #ceil with a digit count (builtin_ops.c)
STRICT_PROGRAMS="test/rational_round_inferred_plan.rb"
sc=0
for f in $STRICT_PROGRAMS; do
  if ! grep -q "^$f: plan-check: " "$OUT"; then
    echo "plan-check: strict program $f did not compile or is missing"
    sc=$((sc + 1))
  elif grep "^$f: plan-check-exit: " "$OUT"; then
    echo "plan-check: strict program $f did not compile"
    sc=$((sc + 1))
  elif grep "^$f: plan-check: unrecorded:" "$OUT"; then
    sc=$((sc + 1))
  fi
done
# Emission trials must preserve the inferred user target of the real call.
STRICT_UCALL_PROGRAMS="test/call_plan_reflection_override.rb test/call_plan_literal_send.rb test/call_plan_conversion.rb test/call_plan_pinned_target.rb test/call_plan_class_target.rb test/call_plan_operator_target.rb test/call_plan_comparison_target.rb test/call_plan_reader_target.rb test/call_plan_break_target.rb
 test/call_plan_delegated_protocol.rb test/call_plan_builtin_object.rb test/call_plan_poly_operator_override.rb
 test/poly_dispatch_builtin_enum_arm.rb
 test/call_plan_descendant_targets.rb test/call_plan_descendant_string.rb
 test/call_plan_misc_targets.rb test/call_plan_native_block_value.rb
 test/call_plan_reader_block_override.rb test/call_plan_rebound_output.rb
 test/devirt_call_return_box.rb test/obj_class_cmethod_subclass_self.rb
 test/rational_complex_reopen_shared_name.rb test/object_spaceship_reopened_object.rb test/bool_reopen_sides.rb
 test/exception_accessor_dispatch_class.rb test/kernel_reopen_public_receiver.rb"
for f in $STRICT_UCALL_PROGRAMS; do
  if ! grep -q "^$f: plan-check: " "$OUT" ||
     grep -q "^$f: plan-check-exit:" "$OUT" ||
     grep "^$f: plan-check: ucall-unrecorded:" "$OUT"; then
    echo "plan-check: strict user program $f failed"
    sc=$((sc + 1))
  fi
done
# The conversion fixture must exercise its separate helper record too.
if ! grep -q '^test/call_plan_conversion.rb: plan-check: conversion-agree:' "$OUT"; then
  echo "plan-check: strict conversion program lost its helper record"
  sc=$((sc + 1))
fi
echo "plan-check: strict programs: $sc failures"
rm -f "$OUT"
[ "$cv" -eq 0 ] && [ "$nc" -eq 0 ] && [ "$nu" -eq 0 ] && [ "$nr" -eq 0 ] && [ "$uc" -eq 0 ] && [ "$ur" -eq 0 ] && [ "$pc" -eq 0 ] && [ "$pm" -eq 0 ] && [ "$ppc" -eq 0 ] && [ "$ppm" -eq 0 ] && [ "$ppe" -eq 0 ] && [ "$rfw" -eq 0 ] && [ "$irc" -eq 0 ] && [ "$sc" -eq 0 ]
