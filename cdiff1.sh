#!/bin/bash
# usage: cdiff1.sh BASE NEW_SPINEL OUTDIR FILE
# Records FILE in OUTDIR/changed.txt, and its diff in OUTDIR/diffs/, when
# the two compilers emit different C for it. BASE is the base compiler, or a
# directory holding its C for FILE in BASE/c/FILE.c (cbase1.sh).
# a compile that runs away (memory or time) fails alone instead of taking the runner down with it
lim() { ( ulimit -v 2000000; ulimit -f 400000; timeout 120 "$@" ) 2>&1; }
if [ -d "$1" ]; then a=$(cat "$1/c/$4.c"); else a=$(lim "$1" "$4" -S --no-line-map); fi
b=$(lim "$2" "$4" -S --no-line-map)
[ "$a" = "$b" ] && exit 0
echo "$4" >> "$3/changed.txt"
diff <(printf '%s\n' "$a") <(printf '%s\n' "$b") > "$3/diffs/$(echo "$4" | tr / _).diff"
exit 0
