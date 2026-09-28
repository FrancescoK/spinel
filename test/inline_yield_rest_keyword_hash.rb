# A keyword hash no parameter takes degrades to one positional hash at the
# tail of a *rest, on a method inlined because it yields as on a plain call.
# The inlined paths dropped it, so the rest read back without it.

def rest(*r) = yield(r)
g = { b: 2 }
p rest(a: 1) { |x| x }
p rest(**g) { |x| x }
p rest(1, a: 1) { |x| x }

def lead(x, *r) = yield(x, r)
p lead(1, a: 1) { |x, r| [x, r] }
p lead(1, 2, **g) { |x, r| [x, r] }

def opt(o = 0, *r) = yield(o, r)
p opt(1, a: 1) { |o, r| [o, r] }

class Bag
  def each_of(*r) = yield(r)
end
p Bag.new.each_of(a: 1) { |x| x }
p Bag.new.each_of(1, **g) { |x| x }

# a yielding initialize, inlined into its `new`
class Pack
  def initialize(*r)
    @r = r
    yield r
  end
end
Pack.new(a: 1) { |x| p x }
Pack.new(1, **g) { |x| p x }
