#!/bin/sh
# n engine checks (`x = x + 1 if RUBY_ENGINE == "spinel"`), which a desugar
# folds by id: each check's call becomes a TrueNode and its operands
# NilNodes, retyped in place among the program's other calls. A kind index
# that moved each retyped node's id by shifting its kind's ids would make
# the folds quadratic in the program; it moves them all at the next ask, in
# one merge per kind.
n=${1:-100}
awk -v n="$n" 'BEGIN {
  print "x = 0"
  for (i = 0; i < n; i++) printf "x = x + %d if RUBY_ENGINE == \"spinel\"\n", i % 7
  print "p x"
}'
