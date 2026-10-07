# Flag-only: the default build refuses this ("a String is not yet shared by
# reference through an ivar's or a call's Array into an appending iterator
# block"). The Arrays each block walks are fresh -- a split's answer, and a
# method's value that is one -- so each String the block binds and appends
# to is one no other name holds: under --share-strings the route's copy is
# unobservable, as it is for a fresh String handed along. (tools/spin.rb's
# `collect_c(dir, excl).split("\n").each do |c|` is this shape.)
def lines(t) = t.split("\n")
seen = []
out = +""
"x\ny".split("\n").each do |c|
  c << "!"
  seen << c
end
lines("a\nb").each do |c|
  c << "?"
  out << c
  seen << c
end
p out, seen
