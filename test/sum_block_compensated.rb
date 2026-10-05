# A sum with a block folds the block's values as CRuby does: exact, then
# compensated (Kahan-Babuska) from the first Float or from a Float seed,
# a value at a time, so a value + refuses raises before the next block.
a = [3, 0.1, 0.2]
p a.sum { |x| x }
b = [0.1, 0.2, 0.3]
p b.sum { |x| x }
p [1, 2].sum { |x| x * 0.1 }
p [0.1] * 10 == [0.1]*10, ([0.1] * 10).sum { |x| x }
p [1, 2].sum(0.0) { |x| x }
h = { a: 0.1, b: 0.2, c: 0.3 }
p h.sum { |k, v| v }
p (1..3).sum { |i| i * 0.1 }
c = [[0.1, 1], 2][0]
p c.sum { |x| x }
p h.sum(0.0) { |k, v| v }
p h.sum(10) { |k, v| v }
p({ a: 1, b: 2 }.sum { |k, v| v })
p({ a: 1, b: 2 }.sum([]) { |k, v| [v] })
p({ a: 1e100, b: 1.0, c: -1e100 }.sum { |k, v| v })
p({}.sum { |k, v| v })
p({ a: "x" }.sum("") { |k, v| v })
p [0.1, 0.2, 0.3].each.sum(0.0)
p [0.1, 0.2, 0.3].sum(0.0)
p [0.1, 0.2, 0.3].sum(0.0) { |x| x }
p (1..3).sum(0.0) { |i| [0.1, 0.2, 0.3][i - 1] }
e = [[0.1, 0.2, 0.3].each, 1][0]
p e.sum(0.0)
p({ a: 0.1 }.sum(0.0) { |k, v| "s" }) rescue p $!.class
c2 = [[0.1, 0.2, 0.3], 2][0]
p c2.sum { |x| x }
p c2.sum(0.0) { |x| x }
p [1, 0.1, 0.2].sum { |x| x }
p [1, 2, 3].sum { |x| x * 0.1 }
p [1, 2].sum(0.5) { |x| x * 0.1 }
hh = [{ a: 0.1, b: 0.2, c: 0.3 }, 1][0]
p hh.sum(0.0) { |k, v| v }
p hh.sum { |k, v| v }
n = 0
begin
  [1, 2, 3].sum { |x| n += 1; x == 2 ? nil : x }
rescue TypeError => e
  p [n, e.message]
end
begin
  { a: 1, b: 2, c: 3 }.sum { |k, x| n += 1; x == 2 ? nil : x }
rescue TypeError => e
  p [n, e.message]
end
p [0.1, 0.2, 0.3].each.to_a.sum(0.0)
