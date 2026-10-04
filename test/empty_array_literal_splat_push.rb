# A splat pushed, appended, unshifted or prepended onto an empty array
# literal spreads its elements, as it does onto any other array. The
# splatted array went in as the one element: `[].push(*a)` gave [[1, 2]].
# The same for a nil beside a splat onto an Integer or Float literal,
# `[1, 2].unshift(nil, *a)`.
a = [1, 2]
b = [].push(*a)
b << 3
p b, a
p b.equal?(a)
p [].append(*a)
p [].unshift(*a)
p [].prepend(*a)
p [].push(0, *a)
p [].push(*a, 3)
p [].unshift(*a, *a).size

s = ["q", "r"]
t = [].push(*s)
p t, t[0], t.size
p [].push(*a, *s)

# what a splat makes of a nil, a range, a hash, an empty array, a scalar
p [].push(*nil)
p [].push(*(1..3))
p [].push(*{ k: 1, l: 2 })
p [].push(*[])
x = 5
p [].push(*x)

def all(*r) = [].push(*r)
p all(1, "two", :three), all
def anon(*) = [].unshift(*)
p anon(1, 2), anon

class Bag
  def initialize
    @a = [4, 5]
  end

  def to_a = [].push(*@a)
  def with(*r) = [].unshift(*@a, *r)
end
p Bag.new.to_a, Bag.new.with(6)

p [].push(*a).map { |v| v * 2 }
p [].push(*a).sum
p [].push(*a) == a

# a nil beside the splat, onto an Integer or Float literal
p [1, 2].unshift(nil, *a)
p [1.5].prepend(*a, nil)

# with a block beside the call, a statement leaves the splatted array alone
[1, 2].unshift(nil, *a) { |v| v }
[1.5].prepend(nil, *a) { |v| v }
[].push(*a) { |v| v }
p a

# without a splat each argument is one element, as before
p [].push(a), [].push(1, 2), [].unshift(a, 3)
