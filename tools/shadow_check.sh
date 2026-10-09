#!/bin/sh
# #7237: the desugar passes an_tree_only_passes lets the fixpoint skip read
# nothing but the tree. Run the shadow schedule (SP_SHADOW_GEN: every pass
# runs, and a call the skip would have dropped that changes anything all the
# same is a violation) over the benchmarks and a slice of the corpus, and
# fail on a violation by a listed pass -- a pass that came to read types
# must leave the list.
SPINEL=${SPINEL:-bin/spinel}
JOBS=${JOBS:-$(nproc 2>/dev/null || echo 4)}
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-shadow.XXXXXX") || exit 2
trap 'rm -rf "$tmp"' EXIT
{ ls benchmark/*.rb; ls test/*.rb | awk 'NR % 8 == 0'; } > "$tmp/list"
xargs -P "$JOBS" -I{} sh -c 'f="$1"; k=$(printf "%s" "$f" | tr / _);
  SP_SHADOW_GEN=1 timeout 120 "$2" -c --no-line-map "$f" -o "$3/$k.c" >/dev/null 2>"$3/$k.err"; rm -f "$3/$k.c"' \
  _ {} "$SPINEL" "$tmp" < "$tmp/list"
n=$(wc -l < "$tmp/list")
bad=$(cat "$tmp"/*.err | grep 'spinel-shadow: violation .* LISTED' | sort | uniq -c)
if [ -n "$bad" ]; then echo "shadow-check: FAIL (a listed tree-only pass changed something)"; echo "$bad"; exit 1; fi
echo "shadow-check: pass ($n programs)"
