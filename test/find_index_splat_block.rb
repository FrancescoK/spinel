# find_index, index and rindex with a splat argument and a block: an empty
# splat is the block's form, one element is the value's form (the block is
# not used), and more raise ArgumentError.

e = []
one = [6]
two = [6, 7]

# Array, Range, Hash
p [5, 6].find_index(*e) { |x| x == 6 }
p [5, 6].find_index(*one) { false }
p((5..6).find_index(*e) { |x| x == 6 })
p((5..6).find_index(*one) { false })
p({5 => 6}.find_index(*[[5, 6]]) { false })
p({a: 1, b: 2}.find_index(*e) { |k, v| v == 2 })
p [5, 6, 5].rindex(*e) { |x| x == 5 }
p [5, 6, 5].rindex(*one) { false }
p [5, 6].index(*e) { |x| x == 6 }
p [5.5, 6.5].find_index(*e) { |x| x > 6 }
p %w[a b].find_index(*["b"]) { |x| false }
m = [1, "a", nil]
p m.find_index(*e) { |x| x.nil? }
p m.index(*["a"]) { |x| x.nil? }

# Enumerator
p [5, 6].each.find_index(*one) { false }
p [5, 6].each.find_index(*[[6, 2]]) { false }
p [5, 6].each.find_index(*e) { |x| x == 6 }
p [5, 6].each_slice(1).find_index(*e) { |x| x == [6] }
p [5, 6].each_with_index.find_index(*e) { |x, i| i == 1 }
p (1..Float::INFINITY).each.find_index(*e) { |x| x > 3 }
begin
  p [5, 6].each.find_index(*two) { false }
rescue ArgumentError => ex
  puts ex.message
end
begin
  p [1].index(*two) { false }
rescue ArgumentError => ex
  puts ex.message
end

# a method's rest parameter and block, forwarded
def f(*a) = [5, 6].find_index(*a) { |x| x == 6 }
p f, f(5), f(9)
def g(*a, &b) = [5, 6].each.find_index(*a, &b)
p g { |x| x == 6 }
p g(5) { |x| x == 6 }
def h(*, &) = [5, 6].each.find_index(*, &)
p h { |x| x == 6 }
p h(5) { |x| x == 6 }

# an Enumerable class of the program's
class Bag
  include Enumerable
  def initialize(*x) = @x = x
  def each(&) = @x.each(&)
end
p Bag.new(5, 7).find_index(*e) { |x| x == 7 }
p Bag.new(5, 7).find_index(*[7]) { |x| x == 5 }

# other splat operands, a block-pass, break, a block in a loop
def mk = [6]
p [5, 6].find_index(*mk) { |x| x == 5 }
@iv = []
p [5, 6].find_index(*@iv) { |x| x == 6 }
p [5, 6, 0].find_index(*e, &:zero?)
pr = proc { |x| x == 6 }
p [5, 6].find_index(*e, &pr)
p [5, 6].find_index(*[5], &pr)
p [5, 6].find_index(*e) { |x| break 42 if x == 6; false }
p [1, 2, 3].map { |i| [5, 6, 7].find_index(*e) { |x| x == 4 + i } }
[[5, 6], (5..6)].each { |r| p r.find_index(*e) { |x| x == 6 }; p r.find_index(*[5]) { false } }

# a `&b` that holds nil: the call with no arguments answers an Enumerator
def k(*a, &b) = [5, 6, 7].find_index(*a, &b)
p k { |x| x == 7 }
p k(6)
p k.class

# a class's own index keeps the block at every count
class Box
  def index(*a) = "box #{a.inspect} #{block_given? ? yield(6) : '-'}"
end
def call(o, *a) = o.index(*a) { |x| x == 6 }
p call(Box.new)
p call(Box.new, 6)
p call(Box.new, 6, 7)
