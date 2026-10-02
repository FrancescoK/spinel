#!/usr/bin/env bash
# cident.sh -- prove a change leaves every generated C file byte-identical.
#
#   tools/cident.sh <ref-rev>
#
# Compiles every program of the corpus (test/, benchmark/, packages/*/test/
# and optcarrot) to C with -c --no-line-map, once with the compiler of
# <ref-rev> and once with this tree's bin/spinel, and compares the files
# byte for byte. The reference tree is built in a worktree and its C is
# cached under build/cident/<sha>/, so comparing many commits against one
# base costs one build. Programs one side refuses and the other compiles
# are reported too: the set of refused programs must not change either.
#
# A refactor of the analysis -> codegen boundary (#7100) must report
# 0 differing and 0 refusal changes at every commit. Renumbered temps
# (_tN) count as a difference: they mean the emission order changed.
#
# Exit status: 0 identical, 1 some file differs, 2 infrastructure error.
set -u
export LC_ALL=C
ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
cd "$ROOT" || exit 2
REV=${1-}
[ -n "$REV" ] || { echo "usage: $0 <ref-rev>" >&2; exit 2; }
SHA=$(git rev-parse --verify -q "$REV^{commit}") || { echo "cident: unknown revision $REV" >&2; exit 2; }
JOBS=${CIDENT_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 2)}
NEW=$ROOT/bin/spinel
[ -x "$NEW" ] || { echo "cident: build bin/spinel first" >&2; exit 2; }

# The corpus, as paths relative to the tree root.
OC=build/optcarrot-single.rb
list() {
  ls test/*.rb benchmark/*.rb packages/*/test/*.rb 2>/dev/null
  [ -f "$OC" ] && echo "$OC"
}

# emit <spinel> <tree-root> <outdir>: C for every corpus file, or a .refused
# marker where the compiler refuses it. Both compilers read the same source
# tree; each binary still resolves lib/ and packages/ from its own location.
emit() {
  local sp=$1 tree=$2 out=$3
  mkdir -p "$out"
  list | xargs -P "$JOBS" -I{} sh -c '
    f="$1"; sp="$2"; tree="$3"; out="$4"
    key=$(printf "%s" "$f" | tr "/" "_")
    if (cd "$tree" && "$sp" -c --no-line-map "$f" -o "$out/$key.c" >/dev/null 2>&1); then :
    else rm -f "$out/$key.c"; : > "$out/$key.refused"; fi
  ' _ {} "$sp" "$tree" "$out"
}

REFDIR=$ROOT/build/cident/$SHA
# Older caches compiled copied sources in the reference tree.
if [ ! -f "$REFDIR/.same-source-v1" ]; then
  # The C embeds the compiler's own tree path in a few string literals,
  # together with their lengths. A reference tree at a path of the same
  # length as this one lets a plain rename make those bytes equal.
  # Put the tree beside this checkout so even short roots have room for
  # an equal-length path. Reserve a hidden random name atomically: runs
  # from equal-length checkouts must never share a reference tree.
  PARENT=$(cd "$ROOT/.." && pwd -P)
  BASE=${ROOT##*/}
  TMP=
  WT=
  if [ "${#BASE}" -ge 3 ] && [ -w "$PARENT" ]; then
    while :; do
      NAME=.$(tr -dc 'a-z0-9' < /dev/urandom | head -c "$((${#BASE} - 1))")
      CANDIDATE=${PARENT%/}/$NAME
      if mkdir "$CANDIDATE" 2>/dev/null; then
        WT=$CANDIDATE
        break
      fi
      [ -e "$CANDIDATE" ] || [ -L "$CANDIDATE" ] || break
    done
  fi
  if [ -z "$WT" ]; then
    # A tiny basename or unwritable parent needs the temporary placement.
    # Resolve /tmp first: require uses /private/tmp on macOS.
    TMP=$(mktemp -d /tmp/spinel-cident.XXXXXXXX) || exit 2
    TMP=$(cd "$TMP" && pwd -P)
    L=$((${#ROOT} - ${#TMP} - 1))
    [ "$L" -ge 1 ] || {
      rmdir "$TMP"
      echo "cident: cannot reserve a sibling reference tree (basename needs at least 3 bytes and parent must be writable); temporary prefix $TMP/ needs a ROOT of at least $((${#TMP} + 2)) bytes, got ${#ROOT}: $ROOT" >&2
      exit 2
    }
    WT=$TMP/$(printf "%${L}s" "" | tr ' ' x)
  fi
  cleanup() {
    git worktree remove --force "$WT" >/dev/null 2>&1 || rmdir "$WT" 2>/dev/null
    [ -z "$TMP" ] || rmdir "$TMP"
  }
  trap cleanup EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  git worktree add --detach "$WT" "$SHA" >/dev/null 2>&1 || { echo "cident: cannot check out $REV" >&2; exit 2; }
  [ -d "$ROOT/vendor" ] && [ ! -d "$WT/vendor" ] && cp -r "$ROOT/vendor" "$WT/vendor"
  ( cd "$WT" && make -j"$JOBS" -s >/dev/null 2>&1 ) || {
    echo "cident: reference build failed" >&2; git worktree remove --force "$WT" >/dev/null 2>&1; exit 2; }
  # The reference compiles this tree's corpus, so a test added by the change
  # under test is compared too (it is reported if the reference refuses it).
  rm -rf "$REFDIR"; mkdir -p "$REFDIR"
  emit "$WT/bin/spinel" "$ROOT" "$REFDIR"
  # Compiler-owned lib/ or prelude paths can still occur in strings. These
  # canonical prefixes have equal byte lengths, so their C sizes stay valid.
  PATTERN=$(printf '%s' "$WT" | sed 's/[][\\.^$*|]/\\&/g')
  REPLACEMENT=$(printf '%s' "$ROOT" | sed 's/[\\&|]/\\&/g')
  # sed -i takes no suffix argument only in GNU sed; BSD sed (macOS) reads the
  # script as the suffix and fails, leaving the reference paths in place.
  for c in "$REFDIR"/*.c; do
    [ -f "$c" ] || continue
    sed "s|$PATTERN|$REPLACEMENT|g" "$c" > "$c.tmp" && mv "$c.tmp" "$c" || exit 2
  done
  cleanup
  trap - EXIT INT TERM
  : > "$REFDIR/.same-source-v1"
fi

NEWDIR=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cident-new.XXXXXX")
emit "$NEW" "$ROOT" "$NEWDIR"

NORM='s/[0-9]{4}\.[0-9]{2}\.[0-9]{2}\+[0-9]+ revision [0-9a-f]+/REV/g'
same=0; diffn=0; refch=0; refused=0; fresh=0
for f in $(list); do
  key=$(printf "%s" "$f" | tr "/" "_")
  a=$REFDIR/$key; b=$NEWDIR/$key
  # a program added after the reference was cached has nothing to compare
  if [ ! -f "$a.c" ] && [ ! -f "$a.refused" ]; then fresh=$((fresh+1)); continue; fi
  if [ -f "$a.refused" ] && [ -f "$b.refused" ]; then refused=$((refused+1)); continue; fi
  if [ -f "$a.refused" ] || [ -f "$b.refused" ]; then
    refch=$((refch+1))
    if [ -f "$b.refused" ]; then echo "NOW REFUSED: $f"; else echo "NO LONGER REFUSED: $f"; fi
    continue
  fi
  # RUBY_DESCRIPTION names the compiler's own commit; a commit made after
  # the reference was cached changes it and nothing else
  if cmp -s "$a.c" "$b.c" ||
     cmp -s <(sed -E "$NORM" "$a.c") <(sed -E "$NORM" "$b.c"); then same=$((same+1))
  else
    diffn=$((diffn+1))
    echo "DIFFERS: $f"
    diff -u "$a.c" "$b.c" | head -20
  fi
done
rm -rf "$NEWDIR"
echo "cident: $same identical, $diffn differ, $refch refusal changes, $refused refused by both, $fresh not in the reference (against ${SHA:0:9})"
[ "$diffn" -eq 0 ] && [ "$refch" -eq 0 ] || exit 1
