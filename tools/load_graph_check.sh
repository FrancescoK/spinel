#!/bin/sh
# Under --load-model=graph (#9898) each require is a LoadNode carrying the
# file it loads: the one its own call resolved to, also where flatten meets
# a file's requires in another order than its tree has them (a begin's
# ensure before its else) and when two are on one line. The libraries
# CRuby has at boot are LoadNodes ahead of the entry's statements, in the
# order they load.
#
# Each case below is a program (`program NAME SOURCE LIB...`: main.rb from
# SOURCE, and LIB.rb for each LIB, printing its name) and what its
# --dump-ast must hold (`loads NAME BOOTS PATH=FILE...`): the entry's body
# opens with BOOTS boot LoadNodes, in the order --dump-load-graph places
# them, and the program's LoadNodes are exactly the PATH=FILE pairs, the
# path a require names and the end of the path of the file its
# target_file is in the load graph.
SPINEL=${SPINEL:-bin/spinel}
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-loadgraph.XXXXXX") || exit 2
trap 'rm -rf "$tmp"' EXIT
ok=1
fail() { echo "load-graph-test: FAIL ($1)"; ok=0; }

program() {
  name=$1 src=$2; shift 2
  mkdir -p "$tmp/cases/$name"
  printf '%b' "$src" > "$tmp/cases/$name/main.rb"
  for lib in "$@"; do printf 'puts "%s"\n' "$lib" > "$tmp/cases/$name/$lib.rb"; done
}

loads() {
  name=$1 boots=$2; shift 2
  t=$tmp/cases/$name/main.rb
  if ! "$SPINEL" --load-model=graph --dump-load-graph "$t" >"$tmp/graph" 2>"$tmp/err" ||
     ! "$SPINEL" --load-model=graph --dump-ast "$t" >"$tmp/ast" 2>>"$tmp/err"; then
    fail "$name: did not flatten"; sed -n 1,3p "$tmp/err"; return
  fi
  # each LoadNode as its path and its target file
  awk 'FNR == NR { if ($1 == "file") file[$2] = $3; next }
       $1 == "N" && $3 == "LoadNode" { load[$2] = 1 }
       $1 == "S" && $3 == "path" { path[$2] = $4 }
       $1 == "I" && $3 == "target_file" { to[$2] = $4 }
       END { for (id in load) print path[id], file[to[id]] }' "$tmp/graph" "$tmp/ast" > "$tmp/pairs"
  [ "$(wc -l < "$tmp/pairs")" -eq $# ] || { fail "$name: $(wc -l < "$tmp/pairs" | tr -d ' ') LoadNodes, expected $#"; cat "$tmp/pairs"; }
  for want in "$@"; do
    awk -v p="${want%%=*}" -v f="/${want#*=}" '$1 == p && substr($2, length($2) - length(f) + 1) == f { n++ } END { exit n != 1 }' "$tmp/pairs" ||
      { fail "$name: no one LoadNode of \"${want%%=*}\" loads ${want#*=}"; cat "$tmp/pairs"; }
  done
  # the boot LoadNodes open the entry's body, the first placed at 0:-n
  awk -v want="$boots" '
       FNR == NR { if ($1 == "order") order[substr($2, 1, length($2) - 1)] = $3; next }
       $1 == "ROOT" { root = $2 }
       $1 == "R" && $2 == root && $3 == "statements" { st = $4 }
       $1 == "A" && $2 == st && $3 == "body" { n = split($4, body, ",") }
       $1 == "I" && $3 == "boot" { boot[$2] = 1 }
       $1 == "I" && $3 == "target_file" { to[$2] = $4 }
       END { for (k = 0; k < n && (body[k + 1] in boot); k++) ;
             bad = k != want
             for (i = 1; i <= k; i++) { got = order[to[body[i]]]; places = places " " got; bad = bad || got != "0:" (i - 1 - k) }
             if (bad) { print "the entry opens with " k " boot LoadNodes (expected " want "), placed at" places; exit 1 } }' \
    "$tmp/graph" "$tmp/ast" > "$tmp/boot" || fail "$name: $(cat "$tmp/boot")"
}

# requires in a begin's else and ensure, on lines of their own and on one line
program lines 'begin\n  puts "body"\nrescue\n  puts "rescue"\nelse\n  require_relative "a"\nensure\n  require_relative "b"\nend\n' a b
loads lines 0 a=a.rb b=b.rb
program one_line 'begin puts "body"; rescue; puts "rescue"; else require_relative "c"; ensure require_relative "d"; end\n' c d
loads one_line 0 c=c.rb d=d.rb

# libraries CRuby has at boot: Set, Enumerable's methods written in Ruby,
# and the enumerator a break leaves
program boot 's = Set.new([1, 2])\np s.size\np [1, 2].map { |x| break x }\n'
loads boot 3 set=packages/set/set.rb builtins/enumerable=builtins/enumerable.rb builtins/enumerator=builtins/enumerator.rb

[ $ok -eq 1 ] && echo "load-graph-test: pass" || exit 1
