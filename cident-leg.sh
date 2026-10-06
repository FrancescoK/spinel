#!/usr/bin/env bash
# cident-leg.sh TREE OUT BASE -- the cident leg: TREE's own tools/cident.sh
# (`make cident`) against BASE, once plain and once with
# CIDENT_FLAGS=--share-strings, as matz/spinel#7721 asks of a restructuring PR.
#
# OUT/cident.txt starts with one summary line a flavour, as a PR body pastes
# them:
#   cident: <N> programs, <D> differing, <R> refusal changes
#   cident --share-strings: <N> programs, <D> differing, <R> refusal changes
# N counts every program cident.sh looked at (identical, differing, refusal
# changed, refused by both, not in the reference). Below them, each
# flavour's own cident.sh line and the programs it reported, one a line.
# OUT/cident-plain.log and OUT/cident-share-strings.log hold cident.sh's
# whole output (the first lines of each diff included).
#
# A tree without tools/cident.sh gets OUT/cident-missing.txt and no
# cident.txt. CIDENT_JOBS passes through to cident.sh. Always exits 0: the
# result is the file.
set -u
tree=$1 out=$2 base=$3
mkdir -p "$out"
cd "$tree" || exit 0
if [ ! -f tools/cident.sh ]; then
  echo "cident: the head has no tools/cident.sh; no result" | tee "$out/cident-missing.txt"
  exit 0
fi
# cident.sh checks BASE out of this tree's own clone into a worktree, so the
# commit must be here: fetch it as the build job fetches a head
git cat-file -e "$base^{commit}" 2>/dev/null || git fetch -q origin "$base" 2>/dev/null ||
  git fetch -q fork "$base" 2>/dev/null || git fetch -q fork '+refs/heads/ci/*:refs/remotes/fork/ci/*' 2>/dev/null
heads=""; details=""
for flags in "" "--share-strings"; do
  tag=${flags:+ $flags}; name=${flags#--}
  log="$out/cident-${name:-plain}.log"
  t0=$(date +%s)
  CIDENT_FLAGS=$flags bash tools/cident.sh "$base" > "$log" 2>&1; rc=$?
  secs=$(( $(date +%s) - t0 ))
  last=$(grep -E '^cident: [0-9]+ identical, ' "$log" | tail -1)
  if [ -n "$last" ]; then
    # shellcheck disable=SC2046 # five numbers, split on purpose
    set -- $(printf '%s\n' "$last" | sed -E 's/^cident: ([0-9]+) identical, ([0-9]+) differ, ([0-9]+) refusal changes, ([0-9]+) refused by both, ([0-9]+) not in the reference.*/\1 \2 \3 \4 \5/')
    heads+="cident$tag: $(( $1 + $2 + $3 + $4 + $5 )) programs, $2 differing, $3 refusal changes"$'\n'
  else
    # an infrastructure error (exit 2): no counts, and nothing a PR could paste
    heads+="cident$tag: no result (cident.sh exit $rc: $(tail -1 "$log"))"$'\n'
  fi
  details+=$'\n'"cident.sh${tag:- (plain)}, ${secs}s: ${last:-no summary line}"$'\n'
  list=$(grep -E '^(DIFFERS|NOW REFUSED|NO LONGER REFUSED): ' "$log" | sed 's/^/  /')
  [ -n "$list" ] && details+="$list"$'\n'
done
printf '%s%s' "$heads" "$details" > "$out/cident.txt"
cat "$out/cident.txt"
exit 0
