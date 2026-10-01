# MatchData#values_at evaluates every argument, left to right, before it looks
# any of them up: a Range begin before the whole match raises RangeError, an
# unknown group name IndexError, and a later argument's side effect runs first,
# as in CRuby.
def mark(v)
  puts "mark #{v}"
  v
end
md = /(?<x>a)(?<y>b)(c)?/.match("zabz")
p((md.values_at(-6..2, mark(1)) rescue $!))
p((md.values_at(mark(-9)..1, mark(0)) rescue $!.class))
p((md.values_at(:nosuch, mark(2)) rescue $!.class))
p md.values_at(:x, "y", 0, 1..2, mark(-1), [:x, 1][1])
