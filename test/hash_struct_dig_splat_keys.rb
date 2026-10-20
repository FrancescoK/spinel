# Hash and Struct dig expand splats after fixed keys as well as before them.
# spinel: gc-stress
h = {a: {b: 5}}
rest = [:b]
p h.dig(:a, *rest)
p h.dig(:a, *[:b])
p h.dig(*[:a], :b)
p h.dig(:a, :b, *[])
p h.dig(:a, *[:missing])
ih = {1 => {2 => 7}}
r = [2]
p ih.dig(1, *r)
p ih.dig(*[1], 2)
S = Struct.new(:a, :b)
s = S.new(1, [5, 6])
p s.dig(:b, *[0])
p s.dig(*[:b], 1)
p s.dig(:b, 0, *[])
p s.dig(:b, *[9])
H = Struct.new(:h)
sh = H.new({a: {b: 8}})
p sh.dig(:h, *[:a, :b])
p sh.dig(:h, :a, *[:b])
p sh.dig(*[:h], :a, :b)
p sh.dig(:h, *[:a], :b)
