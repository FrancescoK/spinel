#!/bin/bash
# usage: cbase1.sh BASE_SPINEL DIR FILE
# Keeps what the base compiler prints for FILE, as cdiff1.sh would read it,
# in DIR/c/FILE.c.
mkdir -p "$2/c/$(dirname "$3")"
( ulimit -v 2000000; ulimit -f 400000; timeout 120 "$1" "$3" -S --no-line-map ) > "$2/c/$3.c" 2>&1
exit 0
