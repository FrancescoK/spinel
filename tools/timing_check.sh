#!/bin/sh
# --timing / SP_TIMING (#7236): the phases are reported on stderr in the
# documented form, nothing is reported without it, and the C is the same.
SPINEL=${SPINEL:-bin/spinel}
src=test/abstract_raise_override_return.rb
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-timing.XXXXXX") || exit 2
trap 'rm -rf "$tmp"' EXIT
ok=1
fail() { echo "timing-test: FAIL ($1)"; ok=0; }

$SPINEL -c -o "$tmp/off.c" $src 2>"$tmp/off.err" || fail "plain compile"
grep -q 'spinel-timing:' "$tmp/off.err" && fail "timing lines without the flag"
$SPINEL -c --timing -o "$tmp/on.c" $src 2>"$tmp/on.err" || fail "--timing compile"
SP_TIMING=1 $SPINEL -c -o "$tmp/env.c" $src 2>"$tmp/env.err" || fail "SP_TIMING compile"
cmp -s "$tmp/off.c" "$tmp/on.c" || fail "--timing changed the C"
cmp -s "$tmp/off.c" "$tmp/env.c" || fail "SP_TIMING changed the C"
for p in frontend analysis_fixpoint analysis codegen_program write_c; do
  grep -Eq "^spinel-timing: phase=$p ms=[0-9]+\.[0-9]( |$)" "$tmp/on.err" || fail "--timing: no $p line"
  grep -Eq "^spinel-timing: phase=$p ms=" "$tmp/env.err" || fail "SP_TIMING: no $p line"
done
grep -Eq '^spinel-timing: phase=analysis_fixpoint ms=[0-9.]+ rounds=[0-9]+' "$tmp/on.err" || fail "no round count"
# the analysis phases, the re-narrowing loop, and each fixpoint pass summed
# over the rounds
for p in an_desugar_register an_pre_fixpoint an_post_fixpoint an_reconcile_check; do
  grep -Eq "^spinel-timing: phase=$p ms=[0-9.]+$" "$tmp/on.err" || fail "no $p line"
done
grep -Eq '^spinel-timing: phase=analysis_renarrow ms=[0-9.]+ rounds=[0-9]+$' "$tmp/on.err" || fail "no analysis_renarrow line"
grep -Eq '^spinel-timing: pass=infer_write_types ms=[0-9.]+ calls=[1-9][0-9]* changed=[0-9]+$' "$tmp/on.err" ||
  fail "no infer_write_types pass line"
[ "$(grep -c '^spinel-timing: pass=' "$tmp/on.err")" -ge 100 ] || fail "fewer than 100 pass lines"
# the native phases, single unit and split
$SPINEL --timing -o "$tmp/a.out" $src 2>"$tmp/cc1.err" || fail "native compile"
grep -q 'phase=cc_total ms=' "$tmp/cc1.err" || fail "no cc_total"
$SPINEL --timing --jobs=2 -o "$tmp/b.out" $src 2>"$tmp/cc2.err" || fail "split compile"
for p in cc_preprocess cc_split cc_link cc_total; do
  grep -q "phase=$p ms=" "$tmp/cc2.err" || fail "split: no $p"
done
grep -q 'phase=cc_compile ms=[0-9.]* jobs=2' "$tmp/cc2.err" || fail "split: no cc_compile jobs=2"
[ $ok -eq 1 ] && echo "timing-test: pass" || exit 1
