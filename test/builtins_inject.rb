# Enumerable#inject / #reduce's block form (0-arg arity only) is a Ruby
# definition in builtins/enumerable.rb, written as `acc = first; skip =
# true; each { ... }` rather than `acc = nil`, the same accumulator idiom
# min_by/max_by/minmax_by use (a `nil`-seeded local would make `acc` poly,
# #4567). inject and reduce are two independent definitions, not one
# canonicalized to the other, the way a user class's own override of just
# one name leaves the other on Enumerable.
#
# The seeded form (`inject(seed) { }`), the symbol forms (`inject(:+)`,
# `inject(seed, :+)`) and the bare argless call all have no parameter here
# and stay on the existing arity-checked emitter, the same carve-out
# find_index/count have for the forms their own definitions do not cover.
# An operator symbol spelled `&:+` also stays there (desugar_builtin_enum_
# calls declines a raw BlockArgumentNode wrapping a SymbolNode, and a
# symbol-argument fold's synthesized block once desugared, marked "sym_fold"
# for exactly this).
# spinel: share
require "set"

p [1, 2, 3, 4].inject { |acc, x| acc + x }
p [1, 2, 3, 4].reduce { |acc, x| acc + x }
p [1, 2, 3, 4].inject(10) { |acc, x| acc + x }
p [1, 2, 3, 4].inject(:+)
p [1, 2, 3, 4].inject(10, :+)
p [1, 2, 3].inject(:nope) rescue p $!.class

p [1.5, 2.5, 3.0].inject { |acc, x| acc + x }
p ["a", "b", "c"].inject { |acc, x| acc + x }
p [].inject { |acc, x| acc + x }
p [].inject(5) { |acc, x| acc + x }
p [5].inject { |acc, x| acc + x }

h = { a: 1, b: 2, c: 3 }
p h.inject { |acc, pair| acc }
p h.inject(0) { |acc, (k, v)| acc + v }
p h.reduce([]) { |acc, (k, v)| acc << k }

p (1..5).inject { |acc, x| acc + x }
p (1..5).reduce(:+)

e = [1, 2, 3].each
p e.inject { |acc, x| acc + x }

def poly(v) = v
p poly([1, 2, 3]).inject { |acc, x| acc + x }
p poly({ a: 1, b: 2 }).inject(0) { |acc, (k, v)| acc + v }

class Nums
  include Enumerable
  def initialize(*xs); @xs = xs; end
  def each; @xs.each { |x| yield x }; end
end
n = Nums.new(1, 2, 3, 4)
p n.inject { |acc, x| acc + x }
p n.reduce { |acc, x| acc + x }

s = Set.new([1, 2, 3])
p s.inject { |acc, x| acc + x }

def fwd(arr, &b)
  arr.inject(&b)
end
p fwd([1, 2, 3]) { |acc, x| acc + x }

p [1, 2, 3, 4].each_slice(2).inject(0) { |acc, x| acc + x.sum }
p [10, 20].each_with_index.inject(0) { |acc, (v, i)| acc + v + i }

begin
  [1, 2, 3].inject
rescue ArgumentError => err
  puts "ArgumentError: #{err.message}"
end

r = []
[1, 2, 3, 4, 5].inject(0) { |acc, x| r << x; break acc if x == 3; acc + x }
p r
r2 = []
p [1, 2, 3, 4, 5].inject { |acc, x| r2 << x; break "stopped" if x == 3; acc + x }
p r2
r3 = []
p [1, 2, 3, 4, 5].inject { |acc, x| r3 << x; next acc if x == 2; acc + x }
p r3

p [1, 2, 3].inject { |acc, x| acc * x }.class
p [1, 2, 3].inject(&:+)
sum_proc = ->(acc, x) { acc + x }
p [1, 2, 3].inject(&sum_proc)

def fwd2(o, &b)
  o.inject(&b)
end
p fwd2([1, 2, 3]) { |a, x| a + x }
