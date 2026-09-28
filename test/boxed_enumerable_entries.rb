# entries on an Enumerable read out of a container answers its elements in
# a new Array, as on a typed receiver: an Array's, a Hash's [key, value]
# pairs, a Range's members, an Enumerator's values, a Struct's members.
a = [1, 2, 4]
x = [a, "s"][0]
e = x.entries
p e
e << 8
p [a, e.equal?(a)]
p [{ k: 1, j: 2 }, 0][0].entries
p [(1..3), 0][0].entries
p [("a".."c"), 0][0].entries
p [[5, 6].each, 0][0].entries
S = Struct.new(:m, :n)
p [S.new(7, 8), 0][0].entries
acc = []
200.times { |i| acc << [[i, "s"], 0][0].entries }
p [acc.size, acc[199]]
D = Data.define(:q)
p ([D.new(q: 1), 0][0].entries rescue $!.message)
p (["str", 0][0].entries rescue $!.message)
p ([nil, 0][0].entries rescue $!.message)
