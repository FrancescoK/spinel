# An Enumerator yielding two values per step (each_with_index, with_index,
# each_with_object, with_object) held in a local, a parameter, an ivar or a
# global gives a block of map and its kin both values: a lone |x| takes the
# first, a lone |*r| both, and &:m calls m on the first with the second.

e = [5, 6].each_with_index
p e.map { |*r| r }
p e.map { |a| a }
p e.map { |a, b| [a, b] }
p e.map { |a, *r| [a, r] }
p e.map { it }
p e.map { _1 }
p e.any? { |*r| r.size == 2 }
p e.flat_map { |*r| r }
p e.filter_map { |a| a if a > 5 }
p e.find_index { |a| a == 6 }
p e.select { |a| a[1] == 1 }
p e.to_a
e.each { |*r| p r }
e.each { |a| p a }

def g(en) = en.map { |*r| r }
p g([7].each_with_index)
p g([7, 8].each)
def g1(en) = en.map { |a| a }
p g1([7].each_with_index)

h = {a: 1}.each_with_index
p h.map { |*r| r }
p h.map { |a| a }
p h.map(&:first)
p({a: 1}.each_with_index.map(&:first))
p([[1, 2]].each_with_index.map(&:last))

r = (1..2).each_with_index
p r.map { |*x| x }

w = [1, 2].each_with_object([])
p w.map { |*x| x }
p w.map { |a| a }
p w.to_a
wo = [1, 2].each.with_object(:m)
wo.each { |a| p a }
p({a: 1}.each_with_object({}).map { |*x| x })

wi = [1, 2].each.with_index(1)
p wi.map { |*x| x }
p wi.map { |a, *x| [a, x] }
p [1, 2].map.with_index.map { |*x| x }
gen = Enumerator.new { |y| y << 1; y << 2 }.with_index
p gen.map { |*x| x }

$ge = [3].each_with_index
p $ge.map { |*x| x }

class Holder
  def initialize(e) = @e = e
  def rest = @e.map { |*x| x }
end
p Holder.new([4].each_with_index).rest

mixed = [[5].each_with_index, [6].each_with_object(0), [[7, 8]].each]
mixed.each { |en| p en.map { |*x| x } }
mixed.each { |en| p en.map { |x| x } }

# one value per step stays one value
s = [1, 2, 3].each_slice(2)
p s.map { |*x| x }
p s.map(&:first)
t = [[1, 2]].each
p t.map { |*x| x }
p t.map { |a| a }
