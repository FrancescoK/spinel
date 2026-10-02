#!/usr/bin/env bash
# cdiff.sh -- prove a refactor changed no generated code.
#
# Emits C for every test/ and benchmark/ program, and optcarrot, with two
# spinel binaries and compares byte for byte. A pure code movement (see
# refactor_plan.md) must produce an empty report: identical text, identical
# `_tN` numbering. A split that renumbers temps has reordered arms, which is
# a logic change however it looks in the diff.
#
#   tools/cdiff.sh <ref-rev>            # cache a build of <ref-rev>
#   tools/cdiff.sh <old-binary> --bin   # compare against an existing binary
#
# Prefer the revision form. A spinel binary finds lib/ relative to its own
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
LOCK=""
CACHE=""
BUILD_HIT=disabled
cleanup() {
  [ -z "$LOCK" ] || rmdir "$LOCK"
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 2' HUP INT TERM
NEW=$ROOT/bin/spinel

FRESH=0
if [ "${1-}" = "--fresh" ]; then FRESH=1; shift; fi
if [ "${2-}" = "--fresh" ]; then FRESH=1; set -- "$1"; fi
if [ "${2-}" = "--bin" ]; then
  OLD=$1
  [ -x "$OLD" ] || { echo "not executable: $OLD" >&2; exit 2; }
  WT=""
else
  REV=${1-}
  [ -n "$REV" ] || { echo "usage: $0 <ref-rev> | <old-binary> --bin" >&2; exit 2; }
  SHA=$(git rev-parse --verify "$REV^{commit}" 2>/dev/null) || {
    echo "cannot check out $REV" >&2; exit 2; }
  CACHE=${CDIFF_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/spinel-cdiff}
  mkdir -p "$CACHE" || exit 2
  CACHE=$(cd "$CACHE" && pwd -P)
  # Hold the lock through comparison so --fresh cannot remove an active tree.
  mkdir "$CACHE/ref-$SHA.lock" 2>/dev/null || {
    echo "reference cache is in use: $CACHE/ref-$SHA.lock" >&2; exit 2; }
  LOCK=$CACHE/ref-$SHA.lock
  WT=$CACHE/ref-$SHA
  BUILD_HIT=hit
  if [ "$FRESH" -eq 1 ] || [ ! -x "$WT/bin/spinel" ] || [ ! -f "$WT/.cdiff-built" ]; then
    BUILD_HIT=miss
    rm -rf "$WT"
    mkdir -p "$WT" || exit 2
    ( set -o pipefail; git archive "$SHA" | tar -x -C "$WT" ) || {
      echo "cannot check out $REV" >&2; exit 2; }
    # Preserve the provenance that make dist puts in a source archive.
    git rev-parse --short "$SHA" > "$WT/.spinel-dist" || exit 2
    git describe --tags --match '[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]' \
      --match '[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9].[0-9]*' "$SHA" >> "$WT/.spinel-dist" 2>/dev/null || :
    (
      cd "$WT" || exit 2
      export GIT_CEILING_DIRECTORIES="${WT%/*}"
      if command -v ccache >/dev/null 2>&1; then
        export CC="ccache cc"
      elif command -v sccache >/dev/null 2>&1; then
        export CC="sccache cc"
      fi
      make deps >/dev/null 2>&1 && make -j"$JOBS" >/dev/null 2>&1
    ) && [ -x "$WT/bin/spinel" ] && touch "$WT/.cdiff-built" || {
      echo "reference build failed" >&2; exit 2; }
  fi
  OLD=$WT/bin/spinel
  CACHE=$WT/.cdiff-output-v1
  mkdir -p "$CACHE" || exit 2
fi

# Use the same packed source and emission flags as make optcarrot.
if [ ! -d build/optcarrot ]; then
  git clone --depth=1 --branch=experiment/spinel https://github.com/mame/optcarrot.git build/optcarrot || exit 2
fi
# Fiber diagnostics embed this path even with --no-line-map.
OPTCARROT=$WORK/optcarrot.rb
[ -z "$CACHE" ] || OPTCARROT=$CACHE/optcarrot.rb
ruby build/optcarrot/tools/pack-for-spinel.rb > "$OPTCARROT" || exit 2

compare() {
  local f=$1 key=$2 bn=${1##*/} a b output cached="" ref_ok=0 new_ok=0 identical=0
  bn=${bn%.rb}
  a=$WORK/a/$f.c; b=$WORK/b/$f.c
  mkdir -p "${a%/*}" "${b%/*}" "$WORK/results/${f%/*}" || return 2
  if [ "$f" = build/optcarrot.rb ]; then
    set -- "$OPTCARROT"
  else
    set -- "$f"
  fi
  # Line-map path lengths can otherwise move C function split boundaries.
  if [ -n "$CACHE" ]; then cached=$CACHE/$key.c; fi
  if [ -n "$cached" ] && [ -f "$cached" ]; then
    a=$cached
    ref_ok=1
    echo hit > "$WORK/results/$f.cache"
  else
    echo miss > "$WORK/results/$f.cache"
    "$OLD" -c --no-line-map "$@" -o "$a" >/dev/null 2>&1 && ref_ok=1
    if [ "$ref_ok" -eq 1 ] && [ -n "$WT" ]; then
      LC_ALL=C sed "/^#line /s|$OLD_PREFIX/|@ROOT@/|g" "$a" > "$a.tmp" && mv "$a.tmp" "$a" || return 2
      # Publish only complete emissions; failed compilations are retried.
      cp "$a" "$cached.tmp" && mv "$cached.tmp" "$cached" || return 2
      rm -f "$a"
      a=$cached
    fi
  fi
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
      LC_ALL=C sed "/^#line /s|$NEW_PREFIX/|@ROOT@/|g" "$b" > "$b.tmp" && mv "$b.tmp" "$b" || return 2
    fi
    # Matching outputs need no rewrite or second cached C copy.
    if cmp -s "$a" "$b"; then
      identical=1
    else
      # Different commits embed their own build identity; compare without it.
      if [ "$a" = "$cached" ]; then
        a=$WORK/a/$f.c
        cp "$cached" "$a" || return 2
      fi
      for output in "$a" "$b"; do
        LC_ALL=C sed -E 's/[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.[0-9]+)?(\+[0-9]+)? revision [[:xdigit:]]+/@RELEASE@ revision @REV@/g' "$output" > "$output.tmp" &&
          mv "$output.tmp" "$output" || return 2
      done
      cmp -s "$a" "$b" && identical=1
    fi
    if [ "$identical" -eq 1 ]; then
      echo same > "$WORK/results/$f.status"
    else
      echo diff > "$WORK/results/$f.status"
      echo "DIFFERS: $bn"
      diff -u "$a" "$b" | head -20
    fi
  fi
  [ "$a" = "$cached" ] || rm -f "$a"
  rm -f "$b"
}
# Keep each worker's report separate so completion order cannot shuffle it.
OLD_PREFIX=$(printf '%s' "$WT" | sed 's/[][\\.^$*|]/\\&/g')
NEW_PREFIX=$(printf '%s' "$ROOT" | sed 's/[][\\.^$*|]/\\&/g')
export WORK OLD NEW WT CACHE OPTCARROT OLD_PREFIX NEW_PREFIX
export -f compare
# Hash small inputs in one process, and start the largest programs first.
# Include the source tree path because __FILE__ can appear in emitted C.
ruby -rdigest - "$WORK" "$ROOT" "$OPTCARROT" <<'RUBY' || exit 2
work, root, optcarrot = ARGV
files = Dir["test/*.rb", "benchmark/*.rb"] + ["build/optcarrot.rb"]
File.write("#{work}/files", files.sort_by { |f| [f.split("/", 2)[1], f] }.join("\n") + "\n")
entries = files.map do |f|
  source = f == "build/optcarrot.rb" ? optcarrot : f
  content = File.binread(source)
  key = Digest::SHA256.hexdigest(root + "\0" + f + "\0" + source + "\0" + content)
  [f, key, content.bytesize]
end
File.open("#{work}/queue", "w") do |out|
  entries.sort_by { |f, _, size| [-size, f] }.each do |f, key, _|
    out.write("#{f}\0#{key}\0")
  end
end
RUBY
mkdir -p "$WORK/results/test" "$WORK/results/benchmark" "$WORK/results/build" || exit 2
xargs -0 -P "$JOBS" -n 2 bash -c 'compare "$1" "$2" > "$WORK/results/$1.out"' _ < "$WORK/queue" || {
  echo "comparison failed" >&2; exit 2; }
same=0; diffn=0; one=0; skip=0; hits=0; total=0
while IFS= read -r f; do
  [ ! -s "$WORK/results/$f.out" ] || cat "$WORK/results/$f.out"
  read -r status < "$WORK/results/$f.status" || { echo "missing result: $f" >&2; exit 2; }
  read -r hit < "$WORK/results/$f.cache" || exit 2
  [ "$hit" != hit ] || hits=$((hits+1))
  total=$((total+1))
  case "$status" in
    same) same=$((same+1)) ;;
    diff) diffn=$((diffn+1)) ;;
    one) one=$((one+1)) ;;
    skip) skip=$((skip+1)) ;;
    *) echo "missing result: $f" >&2; exit 2 ;;
  esac
done < "$WORK/files"
echo "cdiff caches: reference build $BUILD_HIT, reference C $hits/$total hit"
echo "cdiff: $same identical, $diffn differ, $one one-side, $skip skipped (uncompilable by both sides)"
[ "$diffn" -eq 0 ] && [ "$one" -eq 0 ]
