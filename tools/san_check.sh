#!/usr/bin/env bash
# san_check.sh -- compile the corpus with the compiler built under
# AddressSanitizer and UndefinedBehaviorSanitizer and list what they report.
#
#   tools/san_check.sh [-v] [file.rb ...]
#
# The compiler frees and reuses its own tables while its memos point into
# them. A memo that outlives what it points at reads
# freed memory, and the compile still finishes: what it read is usually the
# old bytes, so the C is the same and no test notices, until the allocator
# hands the block to something else. This runs every program of the corpus
# (test/, benchmark/, packages/*/test/ and optcarrot; or the files named)
# through build/spinel-san with -c, where such a read stops the compile with
# a report, and so does undefined behaviour in the compiler's own arithmetic.
#
# One line a site: the sanitizer's file:line for undefined behaviour, the
# first frame in a .c file for a memory error, with the number of programs
# that reach it and the first of them. -v adds that program's report.
# Leaks are not reported: the compiler frees little before it exits.
#
# Exit status: 0 no report, 1 some program reported, 2 infrastructure error.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2
SP=$ROOT/build/spinel-san
[ -x "$SP" ] || { echo "san-check: build build/spinel-san first (make san-check)" >&2; exit 2; }
VERBOSE=0
[ "${1-}" = "-v" ] && { VERBOSE=1; shift; }
# the Makefile's NPROC chain: nproc is GNU, macOS answers through sysctl
JOBS=${SAN_CHECK_JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)}
LOGS=$(mktemp -d "${TMPDIR:-/tmp}/spinel-san-check.XXXXXX")
trap 'rm -rf "$LOGS"' EXIT
# The instrumented frames are several times the plain ones, and codegen
# recurses once per nesting level of the program.
ulimit -s unlimited 2>/dev/null || ulimit -s 1048576 2>/dev/null || true
export ASAN_OPTIONS="detect_leaks=0${ASAN_OPTIONS:+:$ASAN_OPTIONS}"
export UBSAN_OPTIONS="print_stacktrace=1${UBSAN_OPTIONS:+:$UBSAN_OPTIONS}"

list() {
  if [ $# -gt 0 ]; then printf '%s\n' "$@"; return; fi
  ls test/*.rb benchmark/*.rb packages/*/test/*.rb 2>/dev/null
  [ -f build/optcarrot-single.rb ] && echo build/optcarrot-single.rb
}

# one log per program: a program the compiler refuses is not a finding, a
# sanitizer's report is, whatever the exit status
list "$@" | xargs -P "$JOBS" -I{} sh -c '
  key=$(printf %s "$1" | tr / _)
  "$2" -c --no-line-map "$1" -o "$3/$key.c" > "$3/$key.log" 2>&1
  rm -f "$3/$key.c"
  grep -q "runtime error:\|ERROR: AddressSanitizer" "$3/$key.log" || rm -f "$3/$key.log"
' _ {} "$SP" "$LOGS"
# the command above answers 0 for every program, so anything else is xargs
# itself not running them: no log then means no compile, not no report
[ "${PIPESTATUS[1]}" -eq 0 ] || { echo "san-check: xargs failed, the corpus was not compiled" >&2; exit 2; }

total=$(list "$@" | wc -l)
bad=$(find "$LOGS" -name '*.log' | wc -l)
if [ "$bad" -gt 0 ]; then
  # one line per program and site, "site<TAB>program<TAB>what": the
  # sanitizer's own file:line for undefined behaviour, the first frame in a
  # .c file for a memory error (the frames above it are inlined helpers)
  TAB=$(printf '\t')
  list "$@" | while read -r f; do
    log=$LOGS/$(printf %s "$f" | tr / _).log
    [ -f "$log" ] || continue
    grep -o 'src/[a-z_0-9]*\.[ch]:[0-9]*:[0-9]*: runtime error: .*' "$log" |
      sed "s|^\(src/[^:]*:[0-9]*\):[0-9]*: runtime error: |\1$TAB$f$TAB|" | sort -u -t"$TAB" -k1,1
    if grep -q 'ERROR: AddressSanitizer' "$log"; then
      kind=$(grep -m1 -o 'ERROR: AddressSanitizer: [a-z-]*' "$log" | sed 's/.*: //')
      grep -m1 -o ' in [A-Za-z_0-9]* src/[a-z_0-9]*\.c:[0-9]*' "$log" |
        sed "s|^ in \([^ ]*\) \(.*\)|\2$TAB$f$TAB$kind in \1|"
    fi
  done > "$LOGS/sites"
  cut -f1 "$LOGS/sites" | sort | uniq -c | sort -rn | while read -r n site; do
    first=$(grep -m1 "^$site$TAB" "$LOGS/sites")
    prog=$(printf %s "$first" | cut -f2)
    [ "$n" -eq 1 ] && where="$prog" || where="$n programs, first $prog"
    what=$(printf %s "$first" | cut -f3)
    echo "san-check: $site: $what ($where)"
    if [ "$VERBOSE" -eq 1 ]; then
      log=$LOGS/$(printf %s "$prog" | tr / _).log
      if printf %s "$what" | grep -q '^[a-z-]* in [A-Za-z_0-9]*$'; then
        sed -n '/ERROR: AddressSanitizer/,/^SUMMARY/p' "$log"
      else
        grep -F -A8 "$site:" "$log" | sed -n '2,/^$/p'
      fi
    fi
  done
fi
echo "san-check: $total programs, $bad with a report"
[ "$bad" -eq 0 ]
