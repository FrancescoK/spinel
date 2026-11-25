#!/bin/sh
# Generate the operand-order probe (seed 1, 40 cases a program: 2,508 cases in
# 63 programs) and run it with one or more spinel builds against CRuby.
#
#   ./run_all.sh LABEL=/path/to/bin/spinel [LABEL2=/path/to/other/bin/spinel ..]
#
# Writes ../gen/LABEL.results.tsv for each build and ../gen/families.tsv (non-ok
# cases per family and build), then prints the group table (groups.rb).
# JOBS sets the parallel jobs per build (default 2).
set -e
cd "$(dirname "$0")"
[ $# -ge 1 ] || { sed -n '5p' "$0" >&2; exit 2; }
G=../gen
ruby gen_order.rb "$G" --batch 40 --seed 1
labels=""
for a in "$@"; do
  lb=${a%%=*}; sp=${a#*=}
  ruby run_order.rb "$G" "$sp" --jobs "${JOBS:-2}" --label "$lb" > "$G/$lb.log" 2>&1
  labels="$labels $lb"
done
ruby report.rb "$G" $labels > "$G/families.tsv"
ruby groups.rb "$G" $labels
