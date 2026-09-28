# Hash.new / Array.new written into a slot of another kind box it, like {} / []

x = 1; p x; x = Hash.new; p x
x2 = 1; p x2; x2 = Hash.new(0); x2[:a] += 1; p x2
x3 = 1; p x3; x3 = Array.new; x3 << 3; p x3
x4 = 1; p x4; x4 = Hash.new { |h, k| h[k] = k.to_s }; p x4[:a]; p x4
x5 = "s"; p x5; x5 = Hash.new; x5["k"] = 1; p x5
x6 = [1]; p x6; x6 = Hash.new; p x6
x7 = 1; p x7; x7 = Hash.new(capacity: 4); x7[:b] = 1; p x7

@a = 1; p @a; @a = Hash.new; @a[:a] = 2; p @a
@b = 1.5; p @b; @b = Array.new; @b << 1; p @b
@c = 1; p @c; @c = Hash.new { |h, k| h[k] = 0 }; @c[:a] += 2; p @c

$g1 = 1; p $g1; $g1 = Array.new; $g1 << "a"; p $g1
$g2 = "s"; p $g2; $g2 = Hash.new { |h, k| k }; p $g2[:z]; p $g2

z1 = rand < 2 ? Hash.new : 1; p z1
z2 = rand < 2 ? Hash.new : 1; z2[:a] = 1; p z2
z3 = rand < 2 ? Array.new : 1; z3 << 1; p z3
z4 = rand > 2 ? {a: 1} : Hash.new(7); p z4[:q]
@z5 = rand < 2 ? {a: 1} : Hash.new; p @z5
@z6 = rand > 2 ? [1] : Array.new; @z6 << 4; p @z6

y = nil
y = 1 if rand > 2
w = y || Hash.new
p w

def hash_or_int(n) = n > 0 ? Hash.new : 1
p hash_or_int(1); p hash_or_int(0)

def array_or_int(n)
  return 1 if n == 0
  Array.new
end
p array_or_int(1); p array_or_int(0)

def counts_or_sym(n)
  return :s if n == 0
  Hash.new(0)
end
h = counts_or_sym(1); h[:a] += 1; p h; p counts_or_sym(0)

def ints_or_empty(b) = b ? [1, 2] : Array.new
p ints_or_empty(true); p ints_or_empty(false)

class Holder
  attr_accessor :v
  attr_reader :h

  def initialize; @h = 1; end
  def reset; @h = Hash.new(0); end
  def add; @h[:k] += 1; end
end
o = Holder.new; p o.h; o.reset; o.add; p o.h
o.v = 1; p o.v; o.v = Hash.new(0); o.v[:a] += 1; p o.v

class Tally
  @@h = Hash.new(5)
  def self.go; p @@h[:zz]; @@h[:a] += 1; p @@h; end
end
Tally.go

# the nil-guard fallback of || is the container
n1 = nil || Array.new; n1 << 1; p n1
n2 = nil || Hash.new; n2["k"] = 2; p n2
n3 = 1 && Hash.new; p n3

# a capacity: keyword is evaluated, and is not a default
def capacity_of(tag); puts "capacity #{tag}"; 8; end
cap_l = Hash.new(capacity: 4); cap_l[:a] = 1; p cap_l[:zz]; p cap_l
$cap_g = Hash.new(capacity: 4); $cap_g[:a] = 1; p $cap_g[:zz]; p $cap_g
cap_t = rand > 2 ? {a: 1} : Hash.new(capacity: capacity_of("arm")); p cap_t
class CapHolder
  @@h = Hash.new(capacity: capacity_of("cvar"))
  def self.go; @@h["a"] = 1; p @@h; end
end
CapHolder.go

# a default of another type than the written values widens the values
class Missing
  @@h = Hash.new("missing")
  def self.go; @@h["a"] = 1; p @@h["a"]; p @@h["zz"]; p @@h; end
end
Missing.go

# an inlined yielding method's value is built at its own result type
def fresh_list
  yield
  Array.new
end
def maybe_list(b)
  yield
  b ? ["x"] : Array.new
end
def uses_fresh
  a = fresh_list { 1 }
  a << "s"
  b = maybe_list(false) { 1 }
  b << "t"
  p a, b
  [1.5]
end
p uses_fresh
def make_list = Array.new
ml = make_list; ml << :a; p ml
