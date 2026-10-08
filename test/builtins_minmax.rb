# Enumerable#minmax's block-comparator form is a Ruby definition in
# builtins/enumerable.rb (the blockless default-order form stays on the
# typed emitter's dedicated min/max routines for Array/Hash: only an
# Enumerable includer needs the Ruby computation for that form too).
# spinel: gc-minor
a = [3, 1, 4, 1, 5, 9, 2, 6]
p a.minmax
p a.minmax { |x, y| y <=> x }
p [].minmax
p [7].minmax
w = ["pear", "fig", "banana", "kiwi"]
p w.minmax { |s, t| s.length <=> t.length }
h = { a: 3, b: 1, c: 2 }
p h.minmax
p h.minmax { |x, y| x[1] <=> y[1] }
p (1..10).minmax
p (1..10).minmax { |x, y| y <=> x }
p (1.0..5.0).minmax
p a.each_slice(2).minmax { |x, y| x.sum <=> y.sum }
def poly(v) = v
p poly(a).minmax
p poly(a).minmax { |x, y| y <=> x }
class Nums
  include Enumerable
  def initialize(*xs); @xs = xs; end
  def each; @xs.each { |x| yield x }; end
end
n = Nums.new(3, 1, 4, 1, 5)
p n.minmax
p n.minmax { |x, y| y <=> x }
def fwd(arr, &b)
  arr.minmax(&b)
end
p fwd(a)
p fwd(a) { |x, y| y <=> x }
begin
  [1, "a"].minmax { |x, y| x <=> y }
rescue ArgumentError => e
  puts e.message
end
begin
  n.minmax { |x, y| nil }
rescue ArgumentError => e
  puts e.message
end
