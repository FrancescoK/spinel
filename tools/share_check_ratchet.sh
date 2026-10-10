#!/usr/bin/env bash
# share_check_ratchet.sh -- ratchet the sites --share-check reports (#8328).
#
#   tools/share_check_ratchet.sh
#
# Compiles each program of the sharing corpus (test/share/*.rb,
# test/share/verify/*.rb, test/share/verify/conflicts/*.rb and
# test/share_strings_*.rb) with --share-strings --share-check, and collects
# the copies it reports. Each site is one line of four tab-separated fields:
#
#   program   file:line   Kind (method)   conversion
#
# program is the file given to the compiler. file:line is where the compiler
# places the node (`?:0` for a node it synthesised, such as an arm of the
# dynamic send dispatch, which has no source line); Kind (method) is the
# node's type and method name; conversion is what the check says the emitted
# C does there. The compiler's node id is left out, because ids shift with
# any edit, and so is the number the compiler gives a block parameter it
# renames (`x__bp44` is listed as `x__bp`). A file of the compiler's own tree
# (a package) comes out as the compiler's path, absolute and ending in
# bin/../packages/..; the part up to bin/../ is dropped, so the line does not
# name the checkout. The lines are sorted, and a site that occurs twice stays
# twice.
#
# What breaks a line without a change to the site: an edit to the program
# above the site (the line number moves; delete the old line and the target
# names the new one), a rename of the method or of a synthesised local, and a
# change of the helper the emitter picks (the conversion text names it). The
# `?:0` lines of the dynamic send arms have no line number to move. The
# program path is part of every line, so moving a program renames its lines.
#
# The sites are compared with test/share_check/ratchet.txt, the sites of
# today's master:
#   - a site the list does not have fails and is named: it is a new copy;
#   - a line of the list no site matches fails too, with a request to delete
#     it, so the list only shrinks;
#   - equal sets pass, and the count is printed.
# The sites found are always left in build/share-check-ratchet.got, so a first
# list is `cp build/share-check-ratchet.got test/share_check/ratchet.txt`.
#
# SHARE_CHECK_RATCHET_JOBS sets the number of compiles that run at once
# (default 2).
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
SP=${SPINEL:-$ROOT/bin/spinel}
[ -x "$SP" ] || { echo "share-check-ratchet: build bin/spinel first" >&2; exit 2; }
LIST=test/share_check/ratchet.txt
GOT=build/share-check-ratchet.got
JOBS=${SHARE_CHECK_RATCHET_JOBS:-2}
case $JOBS in ''|*[!0-9]*|0) echo "share-check-ratchet: SHARE_CHECK_RATCHET_JOBS must be positive" >&2; exit 2;; esac
[ -f "$LIST" ] || { echo "share-check-ratchet: $LIST is missing" >&2; exit 2; }
export LC_ALL=C
TAB=$(printf '\t')
export TAB
PARTS=$(mktemp -d "${TMPDIR:-/tmp}/spinel-share-check-ratchet.XXXXXX") || exit 2
trap 'rm -rf "${PARTS:?}"' EXIT
mkdir -p build

# One file per program, so the parallel jobs' lines do not interleave. The
# file name is the program's path with / as @, which no path here contains.
ls test/share/*.rb test/share/verify/*.rb test/share/verify/conflicts/*.rb test/share_strings_*.rb |
  xargs -P "$JOBS" -I{} sh -c '
    p=$1; k=$(printf %s "$p" | tr / @)
    if ! "$2" --share-strings --share-check -c --no-line-map "$p" -o "$3/$k.c" >/dev/null 2>"$3/$k.err"; then
      echo "share-check-ratchet: FAIL $p (compile)" > "$3/$k.fail"
    fi
    rm -f "$3/$k.c"
    grep "^share-check: copy: " "$3/$k.err" > "$3/$k.raw"
    sed -n -E "s|^share-check: copy: ([^ ]+:[0-9]+) node [0-9]+ ([A-Za-z]+) \(([^)]*)\): (.*)\$|$p${TAB}\1${TAB}\2 (\3)${TAB}\4|p" "$3/$k.raw" |
      sed -E "s/__bp[0-9]+/__bp/g; s|${TAB}[^${TAB}]*/bin/\.\./|${TAB}|" > "$3/$k.sites"
    if [ "$(wc -l < "$3/$k.raw")" != "$(wc -l < "$3/$k.sites")" ]; then
      echo "share-check-ratchet: FAIL $p (a report line is not in the format this script reads)" >> "$3/$k.fail"
    fi
    rm -f "$3/$k.err" "$3/$k.raw"
  ' _ {} "$SP" "$PARTS"

nprog=$(find "$PARTS" -name '*.sites' | wc -l | tr -d ' ')
nfail=$(find "$PARTS" -name '*.fail' | wc -l | tr -d ' ')
find "$PARTS" -name '*.fail' -exec cat {} + | sort
find "$PARTS" -name '*.sites' -exec cat {} + | sort > "$GOT"
grep -v '^#' "$LIST" | grep -v '^$' | sort > "$PARTS/list"
new=$(comm -13 "$PARTS/list" "$GOT")
gone=$(comm -23 "$PARTS/list" "$GOT")
nsites=$(wc -l < "$GOT" | tr -d ' ')
ok=1
[ "$nfail" = 0 ] || ok=0
if [ -n "$new" ]; then
  echo "share-check-ratchet: FAIL: --share-check reports $(printf '%s\n' "$new" | wc -l | tr -d ' ') site(s) the list does not have (new copies):"
  printf '%s\n' "$new" | sed 's/^/  /'
  ok=0
fi
if [ -n "$gone" ]; then
  echo "share-check-ratchet: FAIL: $(printf '%s\n' "$gone" | wc -l | tr -d ' ') line(s) of $LIST no longer match a reported site; delete the line(s) (the list only shrinks; a site that only moved with an edit is listed above as new, and its new line replaces the old one):"
  printf '%s\n' "$gone" | sed 's/^/  /'
  ok=0
fi
if [ $ok = 1 ]; then
  echo "share-check-ratchet: pass ($nsites sites in $(cut -f1 "$GOT" | sort -u | wc -l | tr -d ' ') of $nprog programs, all listed in $LIST)"
else
  exit 1
fi
