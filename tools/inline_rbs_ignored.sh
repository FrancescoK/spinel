#!/usr/bin/env bash
# inline_rbs_ignored.sh -- prove that every inline RBS annotation a compile
# warns about was ignored whole (docs/inline-rbs.md).
#
#   tools/inline_rbs_ignored.sh SPINEL PROGRAM.rb [SPINEL FLAGS...]
#
# A warning says an annotation is not applied. That is only true if nothing
# of it reached the C: a fact applied early and reported later still shapes
# the code its readers were compiled to. So the program is compiled once as
# written; every annotation a `warning: inline RBS` line names is then
# removed (the comment blanked, so no line moves, with native same-column
# indented continuation lines and stacked `#:` overloads), and the
# program compiled again. The two C files must be identical byte for byte.
#
# The program's directory is copied whole, so `require_relative` finds the
# same files and a warning in a required file is stripped there. Relative
# flag paths, such as --rbs, resolve from that copied directory. Both
# compiles run from the copy with the same output name, so a path in the C
# is the same in both. Exits 1, saying which lines, when the C differs or
# either compile fails; prints nothing and exits 0 otherwise (a compile
# with no inline RBS warning has nothing to prove and passes).
set -euo pipefail
spinel=$1; prog=$2; shift 2
case $spinel in /*) ;; *) spinel=$(cd "$(dirname "$spinel")" && pwd)/$(basename "$spinel") ;; esac
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-irbignored.XXXXXX") || exit 1
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/src" && cp -RL "$(dirname "$prog")/." "$tmp/src/" || exit 1
name=$(basename "$prog")
cd "$tmp/src" || exit 1
srcdir=$(pwd -P) || exit 1

if ! "$spinel" "$name" "$@" -c --no-line-map -o "$tmp/out.c" 2>"$tmp/with.err"; then
  echo "inline_rbs_ignored: FAIL ($name $*: the compile failed)"; sed -n 1,5p "$tmp/with.err"; exit 1
fi
mv "$tmp/out.c" "$tmp/with.c"

# FILE:LINE[:COL]: warning: inline RBS ...  ->  FILE LINE
if grep -oE '[^ :]+\.rb:[0-9]+(:[0-9]+)?: warning: inline RBS' "$tmp/with.err" > "$tmp/matches"; then
  sed -E 's/^([^:]+):([0-9]+).*/\1 \2/' "$tmp/matches" | sort -u > "$tmp/lines"
else
  rc=$?
  [ "$rc" -eq 1 ] && exit 0
  exit "$rc"
fi
[ -s "$tmp/lines" ] || exit 0

files=$(cut -d' ' -f1 "$tmp/lines" | sort -u)
for f in $files; do
  [ -f "$f" ] || { echo "inline_rbs_ignored: FAIL ($name $*: a warning names $f, which is not a file of the program)"; exit 1; }
  fdir=$(cd "$(dirname "$f")" && pwd -P) || exit 1
  case "$fdir/" in "$srcdir/"*) ;; *) echo "inline_rbs_ignored: FAIL ($name $*: a warning names $f outside the temporary copy)"; exit 1 ;; esac
  lines=$(awk -v f="$f" '$1 == f { printf "%s ", $2 }' "$tmp/lines")
  awk -v lines="$lines" '
    BEGIN { n = split(lines, a, " "); for (i = 1; i <= n; i++) strip[a[i]] = 1 }
    strip[NR] {
      col = match($0, /#(:|[ \t]*@rbs|\[)/)
      prefix = substr($0, 1, col - 1)
      trailing = prefix ~ /[^ \t]/
      if ($0 ~ /^[ \t]*#/) $0 = ""
      else sub(/[ \t]*#(:|[ \t]*@rbs|\[).*$/, "")
      cont = col > 0; print; next
    }
    cont && $0 ~ /^[ \t]*#/ {
      if (index($0, "#") == col) {
        text = substr($0, col + 1)
        if (substr(text, 1, 1) == " ") text = substr(text, 2)
        if (trailing || text ~ /^[ \t]/ || text ~ /^[ \t]*$/ || text ~ /^:/) {
          print ""; next
        }
      }
    }
    { cont = 0; print }
  ' "$f" > "$tmp/stripped"
  cat "$tmp/stripped" > "$f"
done

if ! "$spinel" "$name" "$@" -c --no-line-map -o "$tmp/out.c" 2>"$tmp/without.err"; then
  echo "inline_rbs_ignored: FAIL ($name $*: the compile failed once the warned-about annotations were removed)"
  sed -n 1,5p "$tmp/without.err"; exit 1
fi
if ! cmp -s "$tmp/with.c" "$tmp/out.c"; then
  echo "inline_rbs_ignored: FAIL ($name $*: an annotation reported as not applied changed the C; warned at: $(tr '\n' ' ' < "$tmp/lines"))"
  diff "$tmp/out.c" "$tmp/with.c" | head -10; exit 1
fi
exit 0
