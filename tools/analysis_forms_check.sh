#!/usr/bin/env bash
# analysis_forms_check.sh -- the analysis' compile-time forms, run as the
# graph load model will run them.
#
#   tools/analysis_forms_check.sh [SPINEL]
#
# The inline load model expands a class body's loop over a constant table
# with its text pass (sp_const_loop.c) before the parse; the analysis runs
# the same code with its compile-time evaluator (analyze_ct.c), on graph
# tables or under the test-only switch SPINEL_TABLE_LOOPS=analysis. The
# corpus runs the inline model, so this checks the analysis' side:
#
# - test/analysis-forms/*.rb, the programs the analysis answers (some the
#   text pass refuses), and test/class_table_loop_*.rb, compiled under the
#   switch and run plain, under --int-overflow=promote and under
#   SPINEL_GC_STRESS=1, each against its .expected;
# - test/reject/table_loop_*.rb, which must be refused under the switch
#   too, unless test/analysis-forms/ holds a program of the same name: one
#   the text pass refuses and the analysis answers.
#
# Exit status: 0 all pass, 1 a failure.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 1
SP=${1:-$ROOT/bin/spinel}
TIMEOUT=$ROOT/build/spinel-timeout
[ -x "$TIMEOUT" ] && TO="$TIMEOUT 60" || TO=
export SPINEL_TABLE_LOOPS=analysis
tmp=$(mktemp -d /tmp/spinel-aforms.XXXXXX) || exit 1
trap 'rm -rf "$tmp"' EXIT
ok=1; n=0

for t in test/analysis-forms/*.rb test/class_table_loop_*.rb; do
  [ -f "$t" ] || continue
  b=$(basename "$t" .rb); n=$((n + 1))
  for mode in plain promote; do
    fl=; [ $mode = promote ] && fl=--int-overflow=promote
    if ! "$SP" $fl "$t" -o "$tmp/$b.$mode" >"$tmp/$b.cc" 2>&1; then
      echo "analysis-forms-test: FAIL ($t: $mode compile)"; sed -n 1,5p "$tmp/$b.cc"; ok=0; continue
    fi
    $TO "$tmp/$b.$mode" >"$tmp/$b.out" 2>&1; rc=$?
    [ $rc -eq 0 ] || { echo "analysis-forms-test: FAIL ($t: $mode run exits $rc)"; ok=0; }
    cmp -s "$tmp/$b.out" "$t.expected" ||
      { echo "analysis-forms-test: FAIL ($t: $mode output)"; diff -u "$t.expected" "$tmp/$b.out" | head -10; ok=0; }
    if [ $mode = plain ]; then
      SPINEL_GC_STRESS=1 $TO "$tmp/$b.$mode" >"$tmp/$b.out" 2>&1; rc=$?
      [ $rc -eq 0 ] || { echo "analysis-forms-test: FAIL ($t: run under SPINEL_GC_STRESS=1 exits $rc)"; ok=0; }
      cmp -s "$tmp/$b.out" "$t.expected" ||
        { echo "analysis-forms-test: FAIL ($t: output under SPINEL_GC_STRESS=1)"; diff -u "$t.expected" "$tmp/$b.out" | head -10; ok=0; }
    fi
    rm -f "$tmp/$b.$mode"
  done
done

for t in test/reject/table_loop_*.rb; do
  [ -f "$t" ] || continue
  [ -f "test/analysis-forms/$(basename "$t")" ] && continue
  n=$((n + 1))
  if "$SP" "$t" -c --no-line-map -o "$tmp/r.c" >"$tmp/r.out" 2>&1; then
    echo "analysis-forms-test: FAIL ($t: compiled under SPINEL_TABLE_LOOPS=analysis)"; ok=0
  fi
done

if [ $ok = 1 ]; then echo "analysis-forms-test: pass ($n programs)"; exit 0; fi
exit 1
