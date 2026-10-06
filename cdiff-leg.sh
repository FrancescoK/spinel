#!/usr/bin/env bash
# usage: cdiff-leg.sh HEAD_TREE BASE_TREE OUT CACHE
# The corpus C diff: every program of HEAD_TREE (test/, test/infer/,
# benchmark/, the packages' tests and optcarrot, packed as `make optcarrot`
# packs it) compiled `-S --no-line-map` by both trees' spinel, in HEAD_TREE,
# and compared. OUT gets programs.txt, changed.txt, diffs/, cbase.txt and,
# over the changed programs, the cost tools' repr_diff.txt, c_costs.txt and
# alloc_diff.txt. The base's side comes from CACHE where cbase.py finds it
# still stands; the rest is compiled into CACHE.
#
# Environment: BASE, the base sha (what HEAD_TREE's own test/ and benchmark/
# are compared against before CACHE is kept); CBASE_HIT=true when CACHE was
# restored, BASE_KEY its key (for cbase.txt); ALLOC_MAX (default 400).
# Prints save=true to GITHUB_OUTPUT when CACHE was computed here and may be
# kept. The verify workflow's cdiff leg and pgate's cdiff part run it.
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
h=$1 b=$2
mkdir -p "$3" "$4/c"
out=$(cd "$3" && pwd) C=$(cd "$4" && pwd)
jobs=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
cd "$h" || exit 1
# optcarrot (packed as `make optcarrot` packs it) and the packages' tests too, so a PR's
# "optcarrot and the packages emit the same C" is what this leg checked
repo=$(sed -n 's/^OPTCARROT_REPO *:*= *//p' Makefile); br=$(sed -n 's/^OPTCARROT_BRANCH *:*= *//p' Makefile)
if [ -n "$repo" ] && { [ -d build/optcarrot ] || git clone -q --depth=1 ${br:+--branch=$br} "$repo" build/optcarrot 2>/dev/null; }; then
  ruby build/optcarrot/tools/pack-for-spinel.rb > build/optcarrot-single.rb || rm -f build/optcarrot-single.rb
fi
ls test/*.rb test/infer/*.rb benchmark/*.rb packages/*/test/*.rb build/optcarrot-single.rb 2>/dev/null > "$out/programs.txt"
mkdir -p "$out/diffs"
rc=$(mktemp)
python3 "$here/cbase.py" plan "$h" "$out/programs.txt" "$C" "$rc" > "$out/cbase.txt"
xargs -P "$jobs" -n 1 "$here/cbase1.sh" "$b/spinel" "$C" < "$rc" || true
xargs -P "$jobs" -n 1 "$here/cdiff1.sh" "$C" "$h/spinel" "$out" < "$out/programs.txt" || true
rm -f "$rc"
touch "$out/changed.txt"; sort -o "$out/changed.txt" "$out/changed.txt"
# The cost tools (#7501) over the programs whose C changed: which
# slots changed representation, which costly constructs the C
# gained or lost (in loops and out), and what the two builds
# allocate when run. The head's own copies when it has them,
# else this branch's: costguard/ holds tools/repr_diff.sh,
# c_costs.sh and alloc_diff.sh as of cost-guard ace7e8925, until
# matz/spinel has them. A report, never a failure.
ct="$h/tools"; [ -f "$ct/c_costs.sh" ] || ct="$here/costguard"
# shellcheck disable=SC2046 # program paths hold no spaces
if [ -s "$out/changed.txt" ]; then
  REPR_DIFF_JOBS=$jobs bash "$ct/repr_diff.sh" "$b/spinel" "$h/spinel" $(cat "$out/changed.txt") > "$out/repr_diff.txt" 2>&1 || true
  C_COSTS_JOBS=$jobs bash "$ct/c_costs.sh" "$b/spinel" "$h/spinel" $(cat "$out/changed.txt") > "$out/c_costs.txt" 2>&1 || true
  # each program is built and run on both sides: the first
  # ALLOC_MAX changed programs, and the report says when cut
  amax=${ALLOC_MAX:-400}; n=$(wc -l < "$out/changed.txt")
  ALLOC_DIFF_JOBS=$jobs bash "$ct/alloc_diff.sh" "$b/spinel" "$h/spinel" $(head -n "$amax" "$out/changed.txt") > "$out/alloc_diff.txt" 2>&1 || true
  if [ "$n" -gt "$amax" ]; then echo "  (the first $amax of $n changed programs)" >> "$out/alloc_diff.txt"; fi
fi
if [ "${CBASE_HIT:-}" = true ]; then
  echo "  (cache ${BASE_KEY:-?})" >> "$out/cbase.txt"
else
  # kept only from a head whose test/ and benchmark/ differ from
  # the base's in programs and .expected files alone, so the
  # cache's tree is the base's but for a few programs
  aux=$(git diff --name-only "$BASE" HEAD -- test benchmark |
        grep -v -E '^(test|test/infer|benchmark)/[^/]+\.rb$|\.expected$' || true)
  miss=$(while read -r p; do [ -f "$C/c/$p.c" ] || echo "$p"; done < "$out/programs.txt" | wc -l)
  if [ -z "$aux" ] && [ "$miss" -eq 0 ]; then
    python3 "$here/cbase.py" manifest "$h" "$C"
    [ -n "${GITHUB_OUTPUT:-}" ] && echo save=true >> "$GITHUB_OUTPUT"
    echo "  (computed, cached as ${BASE_KEY:-?})" >> "$out/cbase.txt"
  else
    echo "  (computed, not cached: $miss programs without C; other files differ from the base: $(echo "$aux" | tr '\n' ' ' | cut -c1-200))" >> "$out/cbase.txt"
  fi
fi
exit 0
