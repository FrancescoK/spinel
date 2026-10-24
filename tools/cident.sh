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
# CIDENT_FLAGS adds compiler flags to both sides (e.g.
# CIDENT_FLAGS=--int-overflow=promote); the reference cache is kept per
# flag set.
#
# A reference of the same revision and flags built for another corpus is
# reused: only the programs the change of corpus can reach are compiled
# again. CIDENT_REF_ONLY=1 builds the reference and stops; CIDENT_KEEP (20)
# is how many references are kept.
#
# Exit status: 0 identical, 1 some file differs, 2 infrastructure error.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
REV=${1-}
[ -n "$REV" ] || { echo "usage: $0 <ref-rev>" >&2; exit 2; }
SHA=$(git rev-parse --verify -q "$REV^{commit}") || { echo "cident: unknown revision $REV" >&2; exit 2; }
JOBS=${CIDENT_JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu)}
NEW=$ROOT/bin/spinel
[ -x "$NEW" ] || { echo "cident: build bin/spinel first" >&2; exit 2; }

# The corpus, as paths relative to the tree root.
OC=build/optcarrot-single.rb
list() {
  ls test/*.rb benchmark/*.rb packages/*/test/*.rb 2>/dev/null
  # the String-sharing programs share-strings-test compiles, which exercise
  # what the corpus above reaches least (stage 2 of the one representation
  # takes the share analysis apart under them)
  find test/share -name '*.rb' 2>/dev/null | LC_ALL=C sort
  [ -f "$OC" ] && echo "$OC"
}

# emit <spinel> <tree-root> <outdir>: C for every corpus file, or a .refused
# marker where the compiler refuses it. Paths stay relative so that the
# compiler's own tree resolves lib/ and packages/.
emit() {
  local sp=$1 tree=$2 out=$3 only=${4-}
  mkdir -p "$out"
  { if [ -n "$only" ]; then cat "$only"; else list; fi; } | xargs -P "$JOBS" -I{} sh -c '
    f="$1"; sp="$2"; tree="$3"; out="$4"
    key=$(printf "%s" "$f" | tr "/" "_")
    if (cd "$tree" && ulimit -v 16000000 2>/dev/null; $CIDENT_TO "$sp" -c --no-line-map $CIDENT_FLAGS "$f" -o "$out/$key.c" >/dev/null 2>&1); then :
    else rm -f "$out/$key.c"; : > "$out/$key.refused"; fi
  ' _ {} "$sp" "$tree" "$out"
}

CIDENT_FLAGS=${CIDENT_FLAGS-}
export CIDENT_FLAGS
# A compiler that never finishes a program (the reference compiler on a test
# written for a fix it lacks: #7882) held a lane for an hour and 20 GB. Each
# compile gets a time and a memory limit; one that hits it counts as refused.
CIDENT_TO=
for t in timeout gtimeout; do command -v $t >/dev/null 2>&1 && { CIDENT_TO="$t ${CIDENT_TIMEOUT:-300}"; break; }; done
export CIDENT_TO
FLAGKEY=$(printf "%s" "$CIDENT_FLAGS" | tr -c 'A-Za-z0-9=' '_')
# Include supporting files as well as entry points: require_relative and
# compile-time reads can change a program without changing its own bytes.
CORPUS=$(find test benchmark packages/*/test -type f 2>/dev/null; [ -f "$OC" ] && echo "$OC")
CORPUS=$(printf '%s\n' "$CORPUS" | LC_ALL=C sort)
CORPUSKEY=$({
  printf '%s\n' "$CORPUS"
  printf '%s\n' "$CORPUS" | git hash-object --stdin-paths
} | git hash-object --stdin)
REFBASE=$ROOT/build/cident/$SHA${FLAGKEY:+-$FLAGKEY}
REFDIR=$REFBASE-$CORPUSKEY
# A cold cache has one builder. Hold the lock through comparison so no
# other run can remove or read its outputs while they are being written.
# The lock is flock(2) on fd 9, which the kernel drops once no process
# holds that descriptor any more, however the holder ended: a run killed
# with SIGKILL leaves no stale lock, and compiles it orphaned keep the
# cache locked only until they exit. macOS has no flock(1); perl has flock.
LOCK=$REFDIR.lock
mkdir -p "$(dirname "$REFDIR")"
exec 9>"$LOCK"
cident_lock() {
  perl -MFcntl=:flock -e 'open(my $fh, ">&=", 9) or die "cident: cannot lock: $!\n";
    flock($fh, LOCK_EX) or die "cident: cannot lock: $!\n"'
}
cident_lock || exit 2
trap 'exit 2' HUP INT TERM
if [ ! -f "$REFDIR/.done" ]; then
  # The C embeds the compiler's own tree path in a few string literals,
  # together with their lengths. A reference tree at a path of the same
  # length as this one lets a plain rename make those bytes equal.
  L=${#ROOT}
  # the process id keeps two runs against the same revision (from two
  # checkouts whose paths have the same length) out of each other's tree.
  # The compiler embeds the resolved path, so /tmp is resolved too (it is
  # /private/tmp on macOS).
  TMPD=$(cd /tmp && pwd -P)
  WT=$(printf "%s/cident-%s-%s%0100d" "$TMPD" "$$" "$SHA" 0 | cut -c1-"$L")
  [ "$L" -ge 20 ] && [ ${#WT} -eq "$L" ] || { echo "cident: cannot place a reference tree beside $ROOT" >&2; exit 2; }
  git worktree remove --force "$WT" >/dev/null 2>&1; rm -rf "$WT"
  git worktree add --detach "$WT" "$SHA" >/dev/null 2>&1 || { echo "cident: cannot check out $REV" >&2; exit 2; }
  # -L: a vendor that is a symlink into another checkout is copied as its
  # files; copied as the link, it dangled from /tmp and the reference built
  # without the RBS extractor, so every inline-RBS program differed
  [ -d "$ROOT/vendor" ] && [ ! -d "$WT/vendor" ] && cp -rL "$ROOT/vendor" "$WT/vendor"
  ( cd "$WT" && make -j"$JOBS" -s >/dev/null 2>&1 ) || {
    echo "cident: reference build failed" >&2; git worktree remove --force "$WT" >/dev/null 2>&1; exit 2; }
  # The reference compiles this tree's corpus, so a test added by the change
  # under test is compared too (it is reported if the reference refuses it).
  rm -rf "$REFDIR"; mkdir -p "$REFDIR"
  # The corpus as the reference saw it: each file's blob and path
  MANIFEST=$(mktemp "${TMPDIR:-/tmp}/spinel-cident-man.XXXXXX")
  paste -d' ' <(printf '%s\n' "$CORPUS" | git hash-object --stdin-paths) <(printf '%s\n' "$CORPUS") > "$MANIFEST"
  # A reference of the same revision and flags for another corpus (each
  # cycle's tests change it) keeps the C of every program the change of
  # corpus cannot reach: only a program that is new or changed, or that names
  # a file that is new or changed (require_relative, a compile-time read), is
  # compiled again. Its .expected files are not read by the compiler.
  # (only this flag set's: the corpus key is hex, and another set's name
  # goes on with its flags, `<sha>-__int_overflow=promote-<key>`)
  # The pattern opens with its own parenthesis: bash 3.2, macOS's /bin/bash,
  # otherwise ends the command substitution at the pattern's closing one.
  PREV=$(ls -dt "$REFBASE"-*/ 2>/dev/null | while read -r d; do
           d=${d%/}; case ${d#"$REFBASE"-} in (*[!0-9a-f]*) continue;; esac
           [ "$d" != "$REFDIR" ] && [ -f "$d/.done" ] && [ -f "$d/.manifest" ] && { echo "$d"; break; }; done)
  ONLY=
  if [ -n "$PREV" ]; then
    ONLY=$(mktemp "${TMPDIR:-/tmp}/spinel-cident-only.XXXXXX")
    # added, changed or removed, either side of the two manifests
    CHANGED=$(LC_ALL=C comm -3 <(LC_ALL=C sort "$PREV/.manifest") <(LC_ALL=C sort "$MANIFEST") |
              sed 's/^\t//' | cut -d' ' -f2- | grep -v '\.expected$' | LC_ALL=C sort -u)
    {
      list | LC_ALL=C sort > "$ONLY.all"
      printf '%s\n' "$CHANGED" | LC_ALL=C comm -12 - "$ONLY.all"
      # a program that names the file, or a directory it is in (a
      # require_relative, a literal read, an autoload directory)
      printf '%s\n' "$CHANGED" | while read -r ch; do
        [ -n "$ch" ] || continue
        b=$(basename "$ch"); set -- "${b%.*}"
        for part in $(dirname "$ch" | tr '/' ' '); do
          case $part in test|benchmark|packages|.) ;; *) set -- "$@" "$part";; esac
        done
        for w in "$@"; do grep -lF -- "$w" $(cat "$ONLY.all") 2>/dev/null; done
      done
      rm -f "$ONLY.all"
    } | LC_ALL=C sort -u > "$ONLY"
    # the rest from the earlier reference, which keeps their C as it was
    list | LC_ALL=C sort | LC_ALL=C comm -23 - "$ONLY" | while read -r f; do
      key=$(printf "%s" "$f" | tr "/" "_")
      [ -f "$PREV/$key.c" ] && cp "$PREV/$key.c" "$REFDIR/"
      [ -f "$PREV/$key.refused" ] && cp "$PREV/$key.refused" "$REFDIR/"
    done
    echo "cident: reference C of $(git rev-parse --short "$SHA") reused from an earlier corpus, $(grep -c . "$ONLY") program(s) compiled again" >&2
  fi
  # Only the programs: the reference keeps its own lib/, builtins and
  # package sources, which are part of what is being compared.
  cp -r test benchmark "$WT/" 2>/dev/null
  for d in packages/*/test; do mkdir -p "$WT/$d" && cp -r "$d/." "$WT/$d/"; done
  [ -f "$OC" ] && mkdir -p "$WT/build" && cp "$OC" "$WT/$OC"
  emit "$WT/bin/spinel" "$WT" "$REFDIR" "$ONLY"
  # no sed -i: BSD sed takes its argument as a backup suffix (a reused file
  # names $ROOT already and is left as it is)
  for c in "$REFDIR"/*.c; do
    [ -f "$c" ] && grep -qF "$WT" "$c" && LC_ALL=C sed "s|$WT|$ROOT|g" "$c" > "$c.tmp" && mv "$c.tmp" "$c"
  done
  git worktree remove --force "$WT" >/dev/null 2>&1
  mv "$MANIFEST" "$REFDIR/.manifest"; [ -n "$ONLY" ] && rm -f "$ONLY"
  : > "$REFDIR/.done"
  # Keep the newest references (CIDENT_KEEP, 20): each holds the C of the
  # whole corpus, and a lane machine filled its disk with them. One another
  # run holds the lock of is left alone.
  ls -dt "$ROOT"/build/cident/*/ 2>/dev/null | tail -n +"$(( ${CIDENT_KEEP:-20} + 1 ))" | while read -r d; do
    d=${d%/}
    [ "$d" = "$REFDIR" ] && continue
    perl -MFcntl=:flock -e 'open(my $fh, ">>", $ARGV[0]) or exit 1; flock($fh, LOCK_EX|LOCK_NB) or exit 1;
      system("rm", "-rf", $ARGV[1]); unlink $ARGV[0]' "$d.lock" "$d"
  done
fi

# CIDENT_REF_ONLY=1: only the reference, cached for the runs to come (built
# right after a push, for the master the next change is compared with)
[ -n "${CIDENT_REF_ONLY-}" ] && { echo "cident: reference of $(git rev-parse --short "$SHA") ready"; exit 0; }

NEWDIR=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cident-new.XXXXXX")
emit "$NEW" "$ROOT" "$NEWDIR"

fzl_seq() { perl -pe 'BEGIN { %n = (); $k = 0 } s/\b_fzl_([0-9a-f]{8}(?:_[0-9a-f]+)?)(?![0-9a-zA-Z])/"_fzl_q" . ($n{$1} \/\/= $k++)/ge'; }
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
  # A frozen literal is named by a hash of its bytes (#10073); one that
  # holds a path (__FILE__, a file read in) is named after the tree it was
  # compiled in, which the reference's is not, though its bytes compare
  # equal once the path is rewritten above. The names are numbered in the
  # order they appear before the second comparison; the bytes still are
  # compared.
  if cmp -s "$a.c" "$b.c" ||
     cmp -s <(sed -E "$NORM" "$a.c" | fzl_seq) <(sed -E "$NORM" "$b.c" | fzl_seq); then same=$((same+1))
  else
    diffn=$((diffn+1))
    echo "DIFFERS: $f"
    diff -u "$a.c" "$b.c" | head -20
  fi
done
rm -rf "$NEWDIR"
echo "cident: $same identical, $diffn differ, $refch refusal changes, $refused refused by both, $fresh not in the reference (against ${SHA:0:9})"
[ "$diffn" -eq 0 ] && [ "$refch" -eq 0 ] || exit 1
