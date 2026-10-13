#!/bin/sh
# Holds the class facts (#8530) of each program against a CRuby run of it
# (tools/cls_fact_check.rb). Run from the repository root.
#
#   tools/cls_fact_check.sh [-j N] PROGRAM.rb...
#
# A program's .args and .stdin are used as the test harness uses them. A
# program CRuby cannot run to the end is still checked on what it ran.
# Prints the violations, prefixed by the program, and exits 1 if any.
set -u
: "${SPINEL:=bin/spinel}"
: "${RUBY:=$HOME/.rbenv/versions/4.0.7/bin/ruby}"
export SPINEL RUBY

if [ "${1:-}" = "--one" ]; then
  t=$2 base=$3/$(printf '%s' "$2" | tr '/' '_')
  SPINEL_CLS_FACTS=1 "$SPINEL" "$t" -c -o "$base.c" 2> "$base.facts" || exit 0
  args=""; [ -f "$t.args" ] && args=$(cat "$t.args")
  stdinf=/dev/null; [ -f "$t.stdin" ] && stdinf=$t.stdin
  : > "$base.trace"
  # shellcheck disable=SC2086
  CLS_FACT_TRACE_OUT=$base.trace timeout 30 "$RUBY" -r ./tools/cls_fact_trace.rb "$t" $args \
    < "$stdinf" > /dev/null 2>&1
  "$RUBY" tools/cls_fact_check.rb "$base.facts" "$base.trace" | sed "s|^|$t: |"
  exit 0
fi

jobs=$(nproc 2>/dev/null || echo 4)
if [ "${1:-}" = "-j" ]; then jobs=$2; shift 2; fi
work=$(mktemp -d "${TMPDIR:-/tmp}/clsfact.XXXXXX") || exit 2
trap 'rm -rf "$work"' EXIT INT TERM
printf '%s\n' "$@" | xargs -P "$jobs" -I{} sh "$0" --one {} "$work" > "$work/out"
sort "$work/out"
[ ! -s "$work/out" ]
