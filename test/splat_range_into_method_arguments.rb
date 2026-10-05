# A Range or an Enumerator splatted into the arguments of a method the
# program defines spreads its members over the parameters, as its to_a
# does. It was bound as the one value: `f(*(3..4))` answered [3..4] for a
# rest parameter and [[3..4], 0] for two required ones, and summing the
# rest raised TypeError.
def rest(*r) = r
def sum(*a) = a.sum
def two(a, b) = [a, b]
def opt(a, b = :none, c = :none) = [a, b, c]
p rest(*(3..4)), rest(*1...4), rest(0, *(1..2), 9)
p sum(*1..3)
v = 3..4
p two(*v), two(*(5..6))
p opt(*(1..2)), opt(*(1..3)), opt(*(1...2))
p rest(*("a".."c")), rest(*v, *v).size

# the Range is left as it was, and each call makes its own array
a = rest(*v)
a << 9
p a, v, v.sum, a.equal?(rest(*v))

# bounds known only at run time, an empty Range, a step
def between(lo, hi) = rest(*(lo..hi))
p between(1, 3), between(2, 2), between(3, 1)
p rest(*(1..7).step(3))

# Enumerators
e = [1, 2, 3].each_slice(2)
p rest(*e), rest(*[4, 5].each), rest(*3.times), rest(*"ab".each_char)
p rest(*[1, 2].each_with_index, 6)

# a keyword beside it, a block, an optional that reads the one before
def kw(a, *r, k: 0) = [a, r, k]
p kw(*(1..3), k: 5)
def blk(a, b, &k) = k.call(a + b)
p blk(*(1..2)) { |x| x * 10 }
def dflt(a, b = a * 2) = [a, b]
p dflt(*(5..5)), dflt(*(5..6))

# methods of a class, a class method, super
class Box
  def add(x, y) = x + y
  def all(*r) = r
  def mine = all(*(1..3))
  def own = self.all(*("x".."y"))
  def self.make(*a) = a
end
class Crate < Box
  def add(*r) = super(*(1..2))
end
box = Box.new
p box.add(*(3..4)), box.all(*(6..7)), Box.make(*(5..6))
p box.mine, box.own, Crate.new.add

# too many members for the parameters is the arity error it is in CRuby
begin
  p two(*(1..3))
rescue ArgumentError
  puts "ArgumentError"
end

# a parameter that holds the Range in one call and an Array in another
def pass(x) = rest(*x)
p pass(1..2), pass([3]), pass(4), pass(nil)

# a class method named new is the program's own method and is given the
# members; the constructor of another class is not touched by it
class Wrap
  def self.new(*a) = a
end
class Wide < Wrap
end
span = 4..5
p Wrap.new(*(1..3)), Wrap.new(0, *span), Wide.new(*span)
