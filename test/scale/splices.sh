#!/bin/sh
# Splices into one class: an included hook whose class_eval block runs K
# class_eval texts in its includer, and K class_eval texts in the class's
# own body, K over a constant list and K over a literal list. A pass that
# rescans the program per splice or per graft grows as K^2.
K=${1:-10}
awk -v K="$K" 'BEGIN {
  print  "module Hook"
  print  "  def self.included(base)"
  print  "    base.class_eval do"
  for (i = 0; i < K; i++) printf "      class_eval \"def h%d = %d\"\n", i, i
  print  "    end"
  print  "  end"
  print  "end"
  print  "class Unit"
  print  "  include Hook"
  for (i = 0; i < K; i++) {
    printf "  class_eval \"def o%d = %d\"\n", i, i
    printf "  N%d = %%w[c%d]\n", i, i
    printf "  N%d.each do |n|\n", i
    print  "    class_eval \"def #{n}_v = 1\""
    print  "  end"
    printf "  %%w[l%d].each do |n|\n", i
    print  "    class_eval \"def #{n}_v = 1\""
    print  "  end"
  }
  print  "end"
  print  "u = Unit.new"
  print  "s = 0"
  for (i = 0; i < K; i++) printf "s += u.h%d + u.o%d + u.c%d_v + u.l%d_v\n", i, i, i, i
  print  "p s"
}'
