#!/bin/sh
# incremental_bench.sh -- what an --incremental build costs, cold and warm.
#
#   tools/incremental_bench.sh [-k K]... [SPINEL]      (default: -k 100 -k 400)
#
# Builds the scale program of test/scale/gen.sh (K units of model / service
# / presenter) to a binary and prints, as a Markdown table, the wall time of
# the plain build (the default: a single unit, or the --jobs split once the
# C reaches 4 MB), of an explicit --jobs=N split (N = the cores), and of the
# --incremental builds: cold on an empty cache, then warm after each of the
# edits tools/incremental_test.sh bounds (each made to the base, built from
# the same path), then a no-op rebuild of the base. The incremental rows are
# measured twice, with --unit-bytes=256K and with 512K, each on a cache of
# its own, and carry the unit and miss counts of --cache-stats. The numbers
# are for the PR and docs/profiling.md and settle the default unit size; a
# quiet machine gives comparable ones. Every build runs with
# SPINEL_INCREMENTAL_STRICT=1, so a fallback cannot pass for a fast build.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
KS=""
while [ $# -gt 0 ]; do
  case "$1" in
    -k) KS="$KS $2"; shift 2 ;;
    *) break ;;
  esac
done
[ -n "$KS" ] || KS="100 400"
SP=${1:-$ROOT/bin/spinel}
case "$SP" in /*) ;; *) SP=$(pwd)/$SP ;; esac
[ -x "$SP" ] || { echo "incremental-bench: build bin/spinel first" >&2; exit 2; }
T=$(mktemp -d "${TMPDIR:-/tmp}/spinel-incremental-bench.XXXXXX") || exit 2
trap 'rm -rf "$T"' EXIT
unset SPINEL_NO_CACHE SPINEL_KEEP_UNITS SPINEL_UNIT_DROP_DECL 2>/dev/null
SPINEL_INCREMENTAL_STRICT=1
export SPINEL_INCREMENTAL_STRICT
NC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
cd "$ROOT" || exit 2

# seconds since the epoch, with a fraction where date has one
now() {
  d=$(date +%s.%N)
  case "$d" in *N) date +%s ;; *) echo "$d" ;; esac
}
# timed LOG CMD...: run CMD with its output in LOG; the wall time in $wall,
# the status in $rc, the --cache-stats counts (if any) in $um
timed() {
  _log=$1; shift
  _t0=$(now)
  "$@" > "$_log" 2>&1
  rc=$?
  wall=$(awk -v a="$_t0" -v b="$(now)" 'BEGIN { printf "%.1f", b - a }')
  um=$(sed -n 's/^spinel: cache: units=\([0-9]*\) hit=[0-9]* miss=\([0-9]*\).*/\1 \/ \2/p' "$_log" | tail -1)
  [ $rc = 0 ] || { um="FAILED (rc=$rc)"; tail -3 "$_log" | sed 's/^/  /' >&2; }
}

# the edits of tools/incremental_test.sh, made to the base in class
# Model<K/2>
edits() {
  m=$(($1 / 2)); b=$2; d=$3
  e() { awk -v m="$m" "\$0 == \"class Model\" m \" < Base\" {f=1} $2 {print}" "$b" > "$d/$1.rb"; }
  e a 'f && /def label = /{sub(/-#\{@tags.size\}/, "+#{@tags.size}"); f=0}'
  e b 'f && /def weight = 2/{sub(/= 2/, "= 3"); f=0}'
  e c 'f && /def weight = 2/{sub(/= 2/, "= 2.5"); f=0}'
  e add-method 'f && /^end$/{print "  def extra = @id + 1"; f=0}'
  printf 'p Model%d.new(0).extra\n' "$m" >> "$d/add-method.rb"
  e add-literal 'f && /def label = /{sub(/"$/, "\" + \"!\""); f=0}'
  e add-ivar 'f && /@extra = nil/{print "    @extra2 = 0"; f=0}'
}
EDITS="a b c add-method add-literal add-ivar"
what() {
  case "$1" in
    a) echo "warm, edit a (a literal in a body)" ;;
    b) echo "warm, edit b (a constant a method returns)" ;;
    c) echo "warm, edit c (a return type Integer -> Float)" ;;
    add-method) echo "warm, a method added (and called)" ;;
    add-literal) echo "warm, a literal added" ;;
    add-ivar) echo "warm, an instance variable added" ;;
  esac
}

echo "| K | build | wall (s), 256K | units / miss, 256K | wall (s), 512K | units / miss, 512K |"
echo "|---|---|---|---|---|---|"
for K in $KS; do
  W=$T/k$K
  mkdir -p "$W/src"
  sh test/scale/gen.sh "$K" > "$W/base.rb"
  edits "$K" "$W/base.rb" "$W"
  P=$W/src/prog.rb
  cp "$W/base.rb" "$P"
  timed "$W/plain.log" "$SP" "$P" -o "$W/plain"
  echo "| $K | plain (default) | $wall | ${um:--} | | |"
  timed "$W/jobs.log" "$SP" "$P" --jobs="$NC" -o "$W/jobs"
  echo "| $K | --jobs=$NC | $wall | ${um:--} | | |"
  for ub in 256K 512K; do
    C=$W/cache-$ub
    rm -rf "$C"
    cp "$W/base.rb" "$P"
    SPINEL_CACHE_DIR=$C timed "$W/$ub.cold.log" "$SP" "$P" --incremental --cache-stats --unit-bytes=$ub -o "$W/inc"
    eval "w_cold_$ub=\$wall; u_cold_$ub=\$um"
    for v in $EDITS; do
      cp "$W/$v.rb" "$P"
      SPINEL_CACHE_DIR=$C timed "$W/$ub.$v.log" "$SP" "$P" --incremental --cache-stats --unit-bytes=$ub -o "$W/inc"
      k=$(echo "$v" | tr - _)
      eval "w_${k}_$ub=\$wall; u_${k}_$ub=\$um"
    done
    cp "$W/base.rb" "$P"
    SPINEL_CACHE_DIR=$C timed "$W/$ub.noop.log" "$SP" "$P" --incremental --cache-stats --unit-bytes=$ub -o "$W/inc"
    eval "w_noop_$ub=\$wall; u_noop_$ub=\$um"
  done
  row() {  # row LABEL KEY
    eval "echo \"| $K | $1 | \$w_$2_256K | \$u_$2_256K | \$w_$2_512K | \$u_$2_512K |\""
  }
  row "--incremental, cold" cold
  for v in $EDITS; do
    k=$(echo "$v" | tr - _)
    row "--incremental, $(what "$v")" "$k"
  done
  row "--incremental, no-op rebuild" noop
  rm -rf "$W"
done
