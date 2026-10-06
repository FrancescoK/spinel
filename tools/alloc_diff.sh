#!/usr/bin/env bash
# alloc_diff.sh -- run the same programs built by two compilers and compare
# what each allocates (#7501).
#
#   tools/alloc_diff.sh REF_SPINEL NEW_SPINEL PROGS...
#
# tools/repr_diff.sh and tools/c_costs.sh say where a change moved a cost;
# this measures it. Each program is compiled by both compilers and each
# binary run once under SPINEL_ALLOC_REPORT (lib/sp_alloc.c), and the
# totals of the report -- allocations and allocated bytes -- are compared.
# A program whose count or bytes grew past the threshold is flagged, e.g.
# #7482's repro, whose bytes grow with the String's length times the
# number of calls. The largest changes are listed either way.
#
# A program runs as the test suite runs it: with the words of PROG.args as
# its arguments and PROG.stdin (else nothing) as its input. A program is
# skipped, and said to be, when it does not compile or run on a side, when
# the two binaries print different output or exit with different statuses,
# or when its source can run differently each time (threads, forks, random
# numbers, the clock, the environment; ALLOC_DIFF_ALL=1 keeps those). A
# program both binaries end the same way, an uncaught exception included,
# is compared.
#
#   ALLOC_DIFF_PCT=20        flag a rise of more than this many percent
#   ALLOC_DIFF_MIN_COUNT=1000  ... and more than this many allocations,
#   ALLOC_DIFF_MIN_BYTES=65536 or more than this many bytes
#   ALLOC_DIFF_TIMEOUT=60    seconds per run
#   ALLOC_DIFF_TOP=10        changes listed
#   ALLOC_DIFF_JOBS=2
#
# Exit status: 0, or 2 on a usage or infrastructure error. The flags are a
# report, not a verdict.
set -u
[ $# -ge 3 ] || { sed -n '3,4p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
REF=$1 NEW=$2; shift 2
[ -x "$REF" ] && [ -x "$NEW" ] || { echo "alloc_diff: $REF and $NEW must be spinel binaries" >&2; exit 2; }
command -v perl > /dev/null || { echo "alloc_diff: needs perl (for the run timeout)" >&2; exit 2; }
JOBS=${ALLOC_DIFF_JOBS:-2}
T=$(mktemp -d "${TMPDIR:-/tmp}/spinel-alloc-diff.XXXXXX") || exit 2
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/b" "$T/r"
export ALLOC_DIFF_TIMEOUT=${ALLOC_DIFF_TIMEOUT:-60} ALLOC_DIFF_ALL=${ALLOC_DIFF_ALL:-}

# One program: `R <prog> <ref count> <ref bytes> <new count> <new bytes>`,
# or `S <prog> <why>`. Each job is keyed by its input position, so no two
# paths share a file.
i=0
for p in "$@"; do i=$((i + 1)); printf '%06d:%s\n' "$i" "$p"; done | xargs -P "$JOBS" -I{} bash -c '
  k=${1%%:*}; p=${1#*:}; d=$4/b/$k; rec=$4/r/$k
  if [ -z "$ALLOC_DIFF_ALL" ]; then
    w=$(grep -o -E "\b(Thread|Ractor|fork|spawn|rand|srand|Random|Time\.now|clock_gettime|sleep|Socket|popen|system|ENV)\b" "$p" | head -1)
    [ -n "$w" ] && { printf "S\t%s\tits source can run differently each time (%s)\n" "$p" "$w" > "$rec"; exit 0; }
  fi
  args=; [ -f "$p.args" ] && args=$(cat "$p.args")
  in=/dev/null; [ -f "$p.stdin" ] && in=$p.stdin
  for side in ref new; do
    sp=$2; [ $side = new ] && sp=$3
    "$sp" "$p" -o "$d.$side" > "$d.$side.cc" 2>&1 || { printf "S\t%s\tdoes not compile with the %s compiler\n" "$p" $side > "$rec"; rm -f "$d".*; exit 0; }
    SPINEL_ALLOC_REPORT="$d.$side.rep" perl -e "alarm shift; exec @ARGV or exit 127" "$ALLOC_DIFF_TIMEOUT" "$d.$side" $args < "$in" > "$d.$side.out" 2>&1
    rc=$?
    [ $rc -eq 142 ] && { printf "S\t%s\ttimed out with the %s compiler\n" "$p" $side > "$rec"; rm -f "$d".*; exit 0; }
    [ -f "$d.$side.rep" ] || { printf "S\t%s\tno allocation report from the %s binary (exit %d)\n" "$p" $side $rc > "$rec"; rm -f "$d".*; exit 0; }
    if [ $side = ref ]; then rref=$rc; else rnew=$rc; fi
  done
  # a report is written at exit, a failing one too: the two runs compare
  # when they end the same way
  if [ $rref -ne $rnew ]; then printf "S\t%s\tthe two binaries exit differently (ref %d, new %d)\n" "$p" $rref $rnew > "$rec"; rm -f "$d".*; exit 0; fi
  if ! cmp -s "$d.ref.out" "$d.new.out"; then printf "S\t%s\tthe two binaries print different output\n" "$p" > "$rec"; rm -f "$d".*; exit 0; fi
  # the side is the file, not its first line: a report can be empty
  awk -v p="$p" "
    { side = FILENAME == ARGV[1] ? 1 : 2 }
    /^alloc;/ { c[side] += \$NF }
    /^# bytes / { b[side] += \$NF }
    END { printf \"R\t%s\t%d\t%d\t%d\t%d\n\", p, c[1], b[1], c[2], b[2] }" "$d.ref.rep" "$d.new.rep" > "$rec"
  rm -f "$d".*' _ {} "$REF" "$NEW" "$T" || { echo "alloc_diff: running the programs failed" >&2; exit 2; }

cat "$T"/r/* 2>/dev/null | LC_ALL=C sort -t "$(printf '\t')" -k2,2 | awk -F'\t' \
  -v pct="${ALLOC_DIFF_PCT:-20}" -v minc="${ALLOC_DIFF_MIN_COUNT:-1000}" \
  -v minb="${ALLOC_DIFF_MIN_BYTES:-65536}" -v top="${ALLOC_DIFF_TOP:-10}" -v total=$# '
  function grew(o, n, m) { return n - o > m && n > o * (1 + pct / 100) }
  function rel(o, n) { return o > 0 ? sprintf("%+.1f%%", (n - o) * 100 / o) : (n > 0 ? "new" : "0%") }
  function absv(v) { return v < 0 ? -v : v }
  $1 == "S" { skip[++ns] = $2 ": " $3; next }
  $1 == "R" {
    np++; prog[np] = $2; rc[np] = $3; rb[np] = $4; nc[np] = $5; nb[np] = $6
    trc += $3; trb += $4; tnc += $5; tnb += $6
    if (grew($3, $5, minc) || grew($4, $6, minb)) flag[++nf] = np
  }
  END {
    printf "alloc_diff: %d of %d programs compared, %d skipped; %d grew past the threshold (+%d%% and +%d allocations or +%d bytes)\n",
      np, total, ns, nf, pct, minc, minb
    printf "  total allocations %d -> %d (%s), bytes %d -> %d (%s)\n", trc, tnc, rel(trc, tnc), trb, tnb, rel(trb, tnb)
    for (k = 1; k <= nf; k++) {
      i = flag[k]
      printf "  GREW %s: allocations %d -> %d (%s), bytes %d -> %d (%s)\n", prog[i], rc[i], nc[i], rel(rc[i], nc[i]), rb[i], nb[i], rel(rb[i], nb[i])
    }
    # the largest changes in bytes, then in count, whichever way they went
    shown = 0
    for (pass = 1; pass <= 2 && np; pass++) {
      for (i = 1; i <= np; i++) used[i] = 0
      first = 1
      for (n = 1; n <= top; n++) {
        best = 0; bv = 0
        for (i = 1; i <= np; i++) {
          v = pass == 1 ? absv(nb[i] - rb[i]) : absv(nc[i] - rc[i])
          if (!used[i] && v > bv) { bv = v; best = i }
        }
        if (!best) break
        used[best] = 1
        if (first) { print (pass == 1 ? "largest changes in bytes:" : "largest changes in allocations:"); first = 0 }
        if (pass == 1) printf "  %s: %+d bytes (%d -> %d)\n", prog[best], nb[best] - rb[best], rb[best], nb[best]
        else printf "  %s: %+d allocations (%d -> %d)\n", prog[best], nc[best] - rc[best], rc[best], nc[best]
      }
    }
    for (k = 1; k <= ns; k++) print "  skipped " skip[k]
  }'
