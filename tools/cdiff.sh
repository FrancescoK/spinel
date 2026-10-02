#!/usr/bin/env bash
# cdiff.sh -- prove a refactor changed no generated code.
#
# Emits C for every test/ and benchmark/ program, and optcarrot, with two
# spinel binaries and compares byte for byte. A pure code movement (see
# refactor_plan.md) must produce an empty report: identical text, identical
# `_tN` numbering. A split that renumbers temps has reordered arms, which is
# a logic change however it looks in the diff.
#
#   tools/cdiff.sh <ref-rev>            # build <ref-rev> in a temp worktree
#   tools/cdiff.sh <old-binary> --bin   # compare against an existing binary
#
# Prefer the worktree form. A spinel binary finds lib/ relative to its own
# path, so a binary COPIED out of its tree cannot resolve `require` or the
# prelude, and those programs then differ for a reason that has nothing to do
# with the change under test.
#
# Exit status is 0 when every file matches.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
cd "$ROOT" || exit 1
JOBS=${CDIFF_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)}
case "$JOBS" in
  *[!0-9]*|""|0) echo "CDIFF_JOBS must be a positive integer" >&2; exit 2 ;;
esac
[ "$JOBS" -gt 0 ] 2>/dev/null || { echo "CDIFF_JOBS must be a positive integer" >&2; exit 2; }
WORK=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cdiff.XXXXXX") || exit 2
WORK=$(cd "$WORK" && pwd -P)
WT=""
cleanup() {
  [ -n "$WT" ] && git worktree remove --force "$WT" >/dev/null 2>&1
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 2' HUP INT TERM
NEW=$ROOT/bin/spinel

if [ "${2-}" = "--bin" ]; then
  OLD=$1
  [ -x "$OLD" ] || { echo "not executable: $OLD" >&2; exit 2; }
  WT=""
else
  REV=${1-}
  [ -n "$REV" ] || { echo "usage: $0 <ref-rev> | <old-binary> --bin" >&2; exit 2; }
  WT=$WORK/ref
  git worktree add --detach "$WT" "$REV" >/dev/null 2>&1 || {
    echo "cannot check out $REV" >&2; exit 2; }
  ( cd "$WT" && make deps >/dev/null 2>&1 && make -j"$JOBS" >/dev/null 2>&1 ) || {
    echo "reference build failed" >&2; exit 2; }
  OLD=$WT/bin/spinel
fi

# Use the same packed source and emission flags as make optcarrot.
if [ ! -d build/optcarrot ]; then
  git clone --depth=1 --branch=experiment/spinel https://github.com/mame/optcarrot.git build/optcarrot || exit 2
fi
ruby build/optcarrot/tools/pack-for-spinel.rb > "$WORK/optcarrot.rb" || exit 2

compare() {
  local f=$1 bn=${1##*/} a b ref_ok=0 new_ok=0
  bn=${bn%.rb}
  a=$WORK/a/$f.c; b=$WORK/b/$f.c
  mkdir -p "${a%/*}" "${b%/*}" "$WORK/results/${f%/*}" || return 2
  if [ "$f" = build/optcarrot.rb ]; then
    set -- "$WORK/optcarrot.rb"
  else
    set -- "$f"
  fi
  # Line-map path lengths can otherwise move C function split boundaries.
  "$OLD" -c --no-line-map "$@" -o "$a" >/dev/null 2>&1 && ref_ok=1
  "$NEW" -c --no-line-map "$@" -o "$b" >/dev/null 2>&1 && new_ok=1
  if [ "$ref_ok" -ne "$new_ok" ]; then
    echo one > "$WORK/results/$f.status"
    if [ "$ref_ok" -eq 0 ]; then echo "ONE SIDE: $bn (ref fails)"
    else echo "ONE SIDE: $bn (new fails)"; fi
  elif [ "$ref_ok" -eq 0 ]; then
    echo skip > "$WORK/results/$f.status"
  else
    # A compiler may still emit #line directives for a package or prelude
    # source in its own tree. Normalize that prefix only in directives, not
    # Ruby strings: both compilers read the same source, including __FILE__.
    if [ -n "$WT" ]; then
      LC_ALL=C sed "/^#line /s|$OLD_PREFIX/|@ROOT@/|g" "$a" > "$a.tmp" && mv "$a.tmp" "$a" || return 2
      LC_ALL=C sed "/^#line /s|$NEW_PREFIX/|@ROOT@/|g" "$b" > "$b.tmp" && mv "$b.tmp" "$b" || return 2
    fi
    if cmp -s "$a" "$b"; then
      echo same > "$WORK/results/$f.status"
    else
      echo diff > "$WORK/results/$f.status"
      echo "DIFFERS: $bn"
      diff -u "$a" "$b" | head -20
    fi
  fi
  rm -f "$a" "$b"
}
# Keep each worker's report separate so completion order cannot shuffle it.
OLD_PREFIX=$(printf '%s' "$WT" | sed 's/[][\\.^$*|]/\\&/g')
NEW_PREFIX=$(printf '%s' "$ROOT" | sed 's/[][\\.^$*|]/\\&/g')
export WORK OLD NEW WT OLD_PREFIX NEW_PREFIX
export -f compare
printf '%s\n' test/*.rb benchmark/*.rb build/optcarrot.rb | LC_ALL=C sort -t / -k2,2 > "$WORK/files" || exit 2
mkdir -p "$WORK/results/test" "$WORK/results/benchmark" "$WORK/results/build" || exit 2
xargs -P "$JOBS" -n 1 bash -c 'compare "$1" > "$WORK/results/$1.out"' _ < "$WORK/files" || {
  echo "comparison failed" >&2; exit 2; }
same=0; diffn=0; one=0; skip=0
while IFS= read -r f; do
  [ ! -s "$WORK/results/$f.out" ] || cat "$WORK/results/$f.out"
  read -r status < "$WORK/results/$f.status" || { echo "missing result: $f" >&2; exit 2; }
  case "$status" in
    same) same=$((same+1)) ;;
    diff) diffn=$((diffn+1)) ;;
    one) one=$((one+1)) ;;
    skip) skip=$((skip+1)) ;;
    *) echo "missing result: $f" >&2; exit 2 ;;
  esac
done < "$WORK/files"
echo "cdiff: $same identical, $diffn differ, $one one-side, $skip skipped (uncompilable by both sides)"
[ "$diffn" -eq 0 ] && [ "$one" -eq 0 ]
