# spinel: int64
# spinel: share
# spinel: gc-minor
# Sum keeps the seed class when empty and boxes a seed of another class.
ia = [1, 2, 3]
fa = [0.5, 0.25]
sa = ["a", "b"]
p ia.sum(Rational(1, 2)) { |x| x }
p ia.sum(Rational(1, 3)) { |x| Rational(x, 2) }
p ia.sum(Complex(1, 1)) { |x| x }
p fa.sum(Rational(1, 2)) { |x| x }
p fa.sum(Complex(1, 1)) { |x| x }
p ia.sum(2**70) { |x| x }
p ia.take(0).sum(Rational(1, 2)) { |x| x }
p ia.take(0).sum(Complex(1, 2)) { |x| x }
p ia.take(0).sum([]) { |x| x }
r = ia.sum(Rational(1, 2)) { |x| x }
p r.class
p sa.sum([]) { |x| [x] }
p sa.take(0).sum([]) { |x| [x] }
q = +"q"
p [q, 1].take(1).sum([]) { |el| [el] }
p [1.5].take(0).sum
p [1.5].take(0).sum.class
p [1.5].take(0).sum(3)
p [1.5].take(0).sum(3) { |x| x }
p [1.0].take(0).sum(-0.0) { |x| x }
p [1.0].take(0).sum(-0.0)
p [Float::INFINITY, 1.0].sum { |x| x }
p [1.0, Float::INFINITY].sum { |x| x }
p [1, 2].sum { |x| x == 1 ? Float::INFINITY : 1.0 }
p [Float::INFINITY, -Float::INFINITY].sum { |x| x }.nan?
p [1e100, 1.0, -1e100].sum { |x| x }
p ["a\0b", "c"].sum("x\0").bytes
s = +"seed"
r = ["x"].sum(s)
p [s, r, r.equal?(s), r.frozen?]
p ["x"].take(0).sum("seed").frozen?
p [[1], [2, 3], []].sum([0])
begin
  [[1], 2, [3]].sum([])
rescue TypeError => e
  p e.message
end
begin
  r = [[1]].take(0).sum([].freeze)
  r << 1
rescue FrozenError => e
  p e.message
end

total = 0
3.times { |i| total += [i, 1.5].sum }
p total
total_seeded = 0
3.times { |i| total_seeded += [i, 1.5].sum(i) }
p total_seeded
# The numeric accumulator also widens for a boxed value without a sum.
plain = 0
3.times { plain += [1.5, "unused"][0] }
p plain

p [1].take(0).sum(-0.0)
$sum_order = []
def sum_int_items
  $sum_order << :array
  [1, 2]
end
def sum_float_seed
  $sum_order << :seed
  0.5
end
p sum_int_items.sum(sum_float_seed)
p $sum_order
