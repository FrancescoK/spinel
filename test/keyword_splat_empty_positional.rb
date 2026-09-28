# Keywords that are only `**` spreads, into a method that takes no
# keywords, are one more positional Hash when they hold a key and no
# argument at all when they are empty: `f(1, **{})` is `f(1)`.

he = {}
hn = { k: 1 }

def opt(a, b = nil) = [a, b]
p opt(1, **he)
p opt(1, **{})
p opt(1, **nil)
p opt(1, **he, **he)

def opt7(a, b = 7) = [a, b]
p opt7(1, **he)

def req(a, b) = [a, b]
begin
  p req(1, **he)
rescue ArgumentError => e
  p e.message
end

def pr2(*r, z) = [r, z]
p pr2(1, 2, **he)
p pr2(1, 2, **hn)
p pr2(1, 2, **{})

def pr3(x, *r, y, z) = [x, r, y, z]
p pr3(1, 2, 3, **he)
p pr3(1, 2, 3, **hn)

def po(a = 5, *r, z) = [a, r, z]
p po(1, **he)
p po(1, **hn)

def blk(a, b = nil, &f) = [a, b, f.call]
p blk(1, **he) { 3 }

def ym(a, b = nil) = yield(a, b)
p ym(1, **he) { |x, y| [x, y] }
def yq(*r, z) = yield(r, z)
p yq(1, 2, **he) { |r, z| [r, z] }

p [1, "s"].map { |v| opt(v, **he) }

def side(n) = (puts "arg #{n}"; n)
def hs(h) = (puts "hash"; h)
p opt(side(1), **hs(he))

class W
  attr_reader :v
  def initialize(a, b = nil) = (@v = [a, b])
  def self.cm(a, b = nil) = [a, b]
end
p W.new(1, **he).v
p W.cm(1, **he)

class Y
  attr_reader :v
  def initialize(*r, z); @v = [r, z]; yield self; end
end
Y.new(1, 2, **he) { |y| p y.v }

class S
  def m(a, b = nil) = [a, b]
end
class T < S
  def m(a, b = nil) = super
end
p T.new.m(1, **he)
p S.new.send(:m, 1, **he)

# a virtual call from the base class
class A
  def q(*r, z) = "a #{r} #{z.inspect}"
  def go(e, n)
    puts q(1, 2, **e)
    puts q(1, 2, **n)
  end
end
class B < A
  def q(*r, z) = "b #{r} #{z.inspect}"
end
A.new.go({}, { k: 1 })
B.new.go({}, { k: 1 })

# a poly receiver
class P
  def m(a, b = nil) = [:p, a, b]
  def q(*r, z) = [:p, r, z]
end
class Q
  def m(a, b = nil) = [:q, a, b]
  def q(*r, z) = [:q, r, z]
end
[P.new, Q.new].each do |o|
  p o.m(1, **he)
  p o.q(1, 2, **he)
  p o.q(1, 2, **hn)
end

S0 = Struct.new(:x, :y)
p S0.new(1, **he)
p S0.new(1, **{})
p S0.new(1, **nil)
S1 = Struct.new(:x)
p S1.new(1, **he)
begin
  p S1.new(1, **hn)
rescue ArgumentError => e
  p e.message
end

# a poly class receiver
class K1
  def self.cm(a, b = nil) = [:k1, a, b]
  def initialize(a, b = nil); @v = [:k1, a, b]; end
  attr_reader :v
end
class K2
  def self.cm(a, b = nil) = [:k2, a, b]
  def initialize(a, b = nil); @v = [:k2, a, b]; end
  attr_reader :v
end
[K1, K2].each do |k|
  p k.cm(1, **he)
  p k.new(1, **he).v
  p k.new(1, **hn).v
end
