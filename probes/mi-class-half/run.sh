#!/bin/bash
# Re-runs this directory's probe table against a spinel binary.
#
# usage: ./run.sh SPINEL [id ...]
#   SPINEL  a spinel binary inside its build tree (bin/spinel of a built checkout).
#   id      probe names (file names without .rb); default: every probe here.
# env:
#   JOBS=N      parallel compiles (default 2, at most 4)
#   MODELS=...  load models (default "inline graph")
#   RECORD=1    rewrite each <id>.cruby (and <id>.rc / <id>.err) from
#               `ruby --enable-frozen-string-literal` first
#
# A probe is <id>.rb with <id>.cruby beside it (CRuby's stdout). Files without
# a .cruby (libraries a probe requires) are not probes. When CRuby exits
# non-zero, <id>.rc holds its exit code and <id>.err the start of its error
# message; the probe is then right only when the binary also exits non-zero
# with that message on stderr. Otherwise it is right only when stdout matches
# and the binary exits 0.
#
# Verdicts: ok, wrong, refused (a compile-time refusal, or a run-time
# NotImplementedError CRuby does not raise), cerror (spinel or the C compiler
# failed without a refusal), crash (a signal), timeout.
# Output: one line per probe and model, the counts, then the Markdown table.
set -u
SPINEL=${1:?usage: run.sh SPINEL [id ...]}
shift
case $SPINEL in /*) ;; *) SPINEL=$PWD/$SPINEL ;; esac
[ -x "$SPINEL" ] || { echo "no spinel at $SPINEL" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd)
JOBS=${JOBS:-2}
[ "$JOBS" -gt 4 ] && JOBS=4
MODELS=${MODELS:-"inline graph"}
TO=$(command -v timeout || command -v gtimeout || true)
[ -n "$TO" ] || { echo "needs timeout (coreutils)" >&2; exit 2; }

shopt -s nullglob
if [ $# -gt 0 ]; then ids="$*"
elif [ "${RECORD:-0}" = 1 ]; then  # libraries a probe requires live in subdirectories
  ids=$(cd "$HERE" && for f in *.rb; do echo "${f%.rb}"; done)
else ids=$(cd "$HERE" && for f in *.cruby; do echo "${f%.cruby}"; done)
fi
[ -n "$ids" ] || { echo "no probes in $HERE" >&2; exit 2; }

if [ "${RECORD:-0}" = 1 ]; then
  for id in $ids; do
    (cd "$HERE" && ruby --enable-frozen-string-literal "$id.rb" > "$id.cruby" 2> "$id.stderr"
     rc=$?
     rm -f "$id.rc" "$id.err"
     if [ $rc -ne 0 ]; then
       echo $rc > "$id.rc"
       head -1 "$id.stderr" | sed -E "s/^.*(in '[^']*'|[0-9]): (.*) \\([A-Za-z:]+\\)\$/\\2/" > "$id.err"
     fi
     rm -f "$id.stderr")
  done
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/probe_run.XXXXXX") || exit 2
case $WORK in */probe_run.*) ;; *) echo "bad work dir" >&2; exit 2 ;; esac
trap 'rm -rf "$WORK"' EXIT

one() {  # one ID MODEL
  id=$1; m=$2; bin=$WORK/$id.$m
  cerr=$(cd "$HERE" && TMPDIR=$WORK $TO 180 "$SPINEL" --load-model=$m "$id.rb" -o "$bin" 2>&1 >/dev/null)
  crc=$?
  if [ ! -x "$bin" ]; then
    msg=$(printf '%s\n' "$cerr" | grep -v 'warning: ' | grep -v 'nothing written' | head -1 | sed "s|$HERE/||g" | cut -c1-140)
    if printf '%s' "$cerr" | grep -q 'refus\|unsupported\|not supported by AOT\|is not supported'; then
      msg=$(printf '%s\n' "$cerr" | grep -v 'warning: ' | grep 'refus\|unsupported\|not supported by AOT\|is not supported' | grep -v 'nothing written' | head -1 | sed "s|$HERE/||g" | cut -c1-140)
      echo "$id	$m	refused	$msg"
    elif [ $crc -eq 124 ]; then echo "$id	$m	timeout	compile"
    elif [ $crc -gt 128 ]; then echo "$id	$m	crash	compile rc=$crc"
    else echo "$id	$m	cerror	$msg"; fi
    return
  fi
  out=$(cd "$HERE" && $TO 30 "$bin" 2>"$bin.err"); rrc=$?
  err=$(head -1 "$bin.err" | sed "s|$HERE/||g" | cut -c1-120)
  allerr=$(cat "$bin.err")
  rm -f "$bin" "$bin.err"
  exp=$(cat "$HERE/$id.cruby")
  if [ $rrc -eq 124 ]; then echo "$id	$m	timeout	run"; return; fi
  if [ $rrc -gt 128 ]; then echo "$id	$m	crash	rc=$rrc $err"; return; fi
  if [ -f "$HERE/$id.rc" ]; then
    want=$(cat "$HERE/$id.err")
    if [ "$out" = "$exp" ] && [ $rrc -ne 0 ] && printf '%s' "$allerr" | grep -qF -- "$want"; then
      echo "$id	$m	ok	"; return; fi
  elif [ "$out" = "$exp" ] && [ $rrc -eq 0 ]; then echo "$id	$m	ok	"; return; fi
  if printf '%s%s' "$out" "$err" | grep -q 'NotImplementedError' && ! printf '%s' "$exp" | grep -q 'NotImplementedError'; then
    echo "$id	$m	refused	run time: $err"; return
  fi
  got=$(printf '%s' "$out" | tr '\n' '/' | sed 's|/$||; s|/| / |g' | cut -c1-100)
  [ $rrc -ne 0 ] && got="$got${got:+ / }$err"
  echo "$id	$m	wrong	$got"
}
export -f one
export HERE WORK SPINEL TO

for id in $ids; do for m in $MODELS; do echo "$id $m"; done; done |
  xargs -P "$JOBS" -n 2 bash -c 'one "$0" "$1"' | sort > "$WORK/results"
cat "$WORK/results"
echo "--- counts"
awk -F'\t' '{c[$2" "$3]++} END {for (k in c) print k, c[k]}' "$WORK/results" | sort
echo "--- table"
cell() {  # cell VERDICT DETAIL
  case $1 in
    ok) printf 'ok' ;;
    wrong) printf 'wrong: `%s`' "$(printf '%s' "$2" | tr '`|' "'/")" ;;
    *) printf '%s' "$1" ;;
  esac
}
printf '| probe | CRuby |'; for m in $MODELS; do printf ' %s |' "$m"; done; echo
printf '|---|---|'; for m in $MODELS; do printf -- '---|'; done; echo
for id in $ids; do
  exp=$(tr '\n' '/' < "$HERE/$id.cruby" | sed 's|/$||; s|/| / |g' | tr '`|' "'/" | cut -c1-100)
  [ -f "$HERE/$id.rc" ] && exp="$exp${exp:+ / }raises: $(cut -c1-60 "$HERE/$id.err" | tr '`|' "'/")"
  printf '| %s | `%s` |' "$id" "$exp"
  for m in $MODELS; do
    line=$(awk -F'\t' -v i="$id" -v m="$m" '$1==i && $2==m' "$WORK/results")
    v=$(printf '%s' "$line" | cut -f3); d=$(printf '%s' "$line" | cut -f4)
    printf ' %s |' "$(cell "$v" "$d")"
  done
  echo
done
