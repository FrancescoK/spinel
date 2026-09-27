#!/bin/bash
# run.sh -- classify extracted ruby/spec examples against spinel.
#
# Usage: tools/rubyspec/run.sh EXTRACTED_DIR [RESULTS_TSV]
#
# Per example: compile with spinel, run, and classify:
#   PASS         compiled, ran, MSPEC-DONE fail=0
#   FAIL         compiled, ran, some expectation failed
#   REJECT       spinel refused to compile (diagnostic recorded + clustered)
#   ERROR        compiled but crashed / timed out / no MSPEC-DONE line
#   HARNESS-SKEW CRuby itself does not pass the extracted program -- the
#                extraction changed meaning; excluded from spinel's score.
#
# Output: one TSV row per example + a summary + the reject-reason ranking,
# which is the "what to implement next" list this harness exists to produce.
#
# Environment knobs:
#   RUBYSPEC_ONLY=<file>  only run the examples named in <file> (one basename
#                         per line, no .rb suffix) -- the retention gate's input
#   RUBYSPEC_GATE=1       skip the CRuby oracle (gate runs re-check examples
#                         already known oracle-clean; CRuby need not be present)
#   RUBYSPEC_JOBS=<n>     parallelism (default: nproc-2, min 1)
set -u
DIR="${1:?usage: run.sh EXTRACTED_DIR [out.tsv]}"
OUT="${2:-$DIR/results.tsv}"
SPINEL="${SPINEL:-bin/spinel}"
ONLY="${RUBYSPEC_ONLY:-}"
GATE="${RUBYSPEC_GATE:-}"
JOBS="${RUBYSPEC_JOBS:-}"
if [ -z "$JOBS" ]; then
  JOBS=$(( $(nproc 2>/dev/null || echo 4) - 2 )); [ "$JOBS" -lt 1 ] && JOBS=1
fi
TDIR=$(mktemp -d /tmp/rubyspec-run.XXXXXX)
trap 'rm -rf "$TDIR"' EXIT

# classify_one FILE: write the example's TSV row to $TDIR/rows/<bn>.
# Runs in a parallel worker, so it writes its own file (no shared append).
classify_one() {
  local f="$1"
  local bn; bn=$(basename "$f" .rb)
  local row="$TDIR/rows/$bn"
  local bin="$TDIR/bin-$bn"
  if [ -z "$GATE" ]; then
    # CRuby oracle first: a skewed extraction must not count against spinel.
    local cr; cr=$(timeout 10 ruby "$f" 2>/dev/null | tail -1)
    if ! grep -q "fail=0" <<<"$cr"; then
      echo -e "$bn\tHARNESS-SKEW\t${cr:-crash}" > "$row"; return
    fi
  fi
  local diag; diag=$("$SPINEL" "$f" -o "$bin" 2>&1 >/dev/null)
  if [ ! -x "$bin" ]; then
    local reason; reason=$(grep -oE "unsupported [^:]*|Parse errors|cannot [a-z ]*|error: [^(]*" <<<"$diag" | head -1)
    # a rejected call names its method: append it so the reject ranking (and
    # the by-design ledger's rules) can see WHICH call, not just "a call"
    case "$reason" in unsupported*call*|unsupported*argument*)
      local mn; mn=$(grep -oE 'CallNode `[A-Za-z_0-9?!=<>]+`' <<<"$diag" | head -1 | sed 's/CallNode //')
      [ -n "$mn" ] && reason="$reason $mn";;
    esac
    echo -e "$bn\tREJECT\t${reason:-unknown}" > "$row"; return
  fi
  local rc last
  # run output goes to a file, NOT a shell variable: an example that prints
  # unboundedly (1.upto(Infinity)) would otherwise balloon the worker
  local run_out="$TDIR/out-$bn"
  timeout 10 "$bin" > "$run_out" 2>&1; rc=$?
  last=$(tail -c 4096 "$run_out" | tail -1)
  rm -f "$bin" "$run_out"
  if [ $rc -ne 0 ] || ! grep -q "MSPEC-DONE" <<<"$last"; then
    echo -e "$bn\tERROR\trc=$rc" > "$row"
  elif grep -q "fail=0" <<<"$last"; then
    echo -e "$bn\tPASS\t$last" > "$row"
  else
    echo -e "$bn\tFAIL\t$last" > "$row"
  fi
}
export -f classify_one
export TDIR SPINEL GATE

mkdir -p "$TDIR/rows"
if [ -n "$ONLY" ]; then
  # one path per listed basename; a listed example missing from the
  # extraction is an immediate error (manifest and extraction diverged)
  : > "$TDIR/files"
  missing=0
  while IFS= read -r bn; do
    [ -z "$bn" ] && continue
    if [ -f "$DIR/$bn.rb" ]; then echo "$DIR/$bn.rb" >> "$TDIR/files"
    else echo "rubyspec: listed example missing from extraction: $bn" >&2; missing=1; fi
  done < "$ONLY"
  [ "$missing" -ne 0 ] && exit 2
else
  ls "$DIR"/*.rb > "$TDIR/files"
fi

xargs -P "$JOBS" -I{} bash -c 'classify_one "$@"' _ {} < "$TDIR/files"

# stitch rows in stable (example-name) order
: > "$OUT"
for row in $(ls "$TDIR/rows" | sort); do cat "$TDIR/rows/$row" >> "$OUT"; done

pass=$(awk -F'\t'   '$2=="PASS"' "$OUT" | wc -l)
fail=$(awk -F'\t'   '$2=="FAIL"' "$OUT" | wc -l)
reject=$(awk -F'\t' '$2=="REJECT"' "$OUT" | wc -l)
error=$(awk -F'\t'  '$2=="ERROR"' "$OUT" | wc -l)
skew=$(awk -F'\t'   '$2=="HARNESS-SKEW"' "$OUT" | wc -l)
total=$((pass+fail+reject+error))
echo "rubyspec: $pass PASS / $fail FAIL / $reject REJECT / $error ERROR  (of $total; +$skew harness-skew excluded)"
echo "--- top reject reasons ---"
awk -F'\t' '$2=="REJECT"{print $3}' "$OUT" | sort | uniq -c | sort -rn | head -12
