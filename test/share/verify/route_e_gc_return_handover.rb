def build(n)
  out = +""
  n.times { |i| out << i.to_s; junk = "j" * 50 }
  out
end
def wrap(s) = (s << "!"; s)
r = []
40.times { |i| x = build(i % 9); y = wrap(x); r << y; r << x }
p r.size, r[-1].equal?(r[-2]), r.map(&:size).sum, r[17]
