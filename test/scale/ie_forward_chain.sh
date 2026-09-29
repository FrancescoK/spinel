#!/bin/sh
K=${1:-2}
awk -v K="$K" 'BEGIN {
  for (i = 1; i <= K; i++) {
    printf "class W%d\n  def initialize(x)\n    @x = x\n  end\n\n  def run(&b)\n    @x.run(&b)\n  end\nend\n\n", i
  }
  print "class Leaf\n  def run(&b)\n    instance_eval(&b)\n  end\n\n  def v\n    7\n  end\nend\n"
  print "obj = Leaf.new"
  for (i = 1; i <= K; i++) printf "obj = W%d.new(obj)\nW%d.new(Leaf.new)\n", i, i
  print "p obj.run { v }"
}'
