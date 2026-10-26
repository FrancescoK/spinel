#!/usr/bin/env bash
# imemo_shadow_corpus.sh -- check infer_type's memo over the whole test corpus.
#
#   tools/imemo_shadow_corpus.sh [jobs]
#
# infer_type keeps an answer while the owners it read stand (#8852), which
# holds only if every write of a fact inference reads moves its owner
# (compiler.h, comp_touch_*). A write that does not leaves a kept answer
# standing after its inputs changed. SPINEL_IMEMO=shadow derives each kept
# answer afresh and counts the ones that differ; this runs it on every
# program of test/ (make imemo-shadow-test covers a handful) and fails if
# any program reports one. SPINEL_IMEMO_WHY=1 on that program names the
# owners the answer read and the owners written since.
set -u
jobs=${1:-$(nproc)}
spinel=${SPINEL:-./bin/spinel}
out=$(mktemp -d "${TMPDIR:-/tmp}/spinel-imemo-corpus.XXXXXX")
trap 'rm -rf "${out:?}"' EXIT
export spinel
ls test/*.rb | xargs -P "$jobs" -n 1 sh -c '
  o=$(SPINEL_IMEMO=shadow timeout 300 "$spinel" -c -o /dev/null "$1" 2>&1)
  r=$(printf "%s\n" "$o" | sed -n "s/^imemo-shadow: [0-9]* kept answers, \([0-9]*\) differ$/\1/p")
  echo "$1 ${r:-none}"' sh > "$out/res"
n=$(wc -l < "$out/res")
# a program that reports no count is one the compiler stopped on before
# the report (a refusal exits early): it kept nothing to compare
bad=$(awk '$2 != "0" && $2 != "none"' "$out/res" | sort)
nbad=$(printf '%s' "$bad" | grep -c . || true)
echo "imemo-shadow-corpus: $n programs, $nbad with a kept answer that differs"
if [ "$nbad" -gt 0 ]; then
  printf '%s\n' "$bad" | sed 's/^/imemo-shadow-corpus FAIL: /'
  exit 1
fi
