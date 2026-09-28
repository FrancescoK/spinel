# A braceless keyword hash into a method with no keyword parameters is one
# more positional argument, the last: past a *rest it fills the last post.

def pr2(*r, z) = [r, z]
p pr2(1, a: 1)
p pr2(a: 1)
p pr2(1, 2, "x" => 2)
h = { a: 1 }
p pr2(1, **h)

def pr3(x, *r, y, z) = [x, r, y, z]
p pr3(1, 2, 3, a: 1)
p pr3(1, 2, a: 1)

def po(a = 5, *r, z) = [a, r, z]
p po(a: 1)
p po(1, a: 1)
p po(1, 2, a: 1)

# a default reading an earlier parameter
def pd(a, b = a, *r, z) = [a, b, r, z]
p pd(1, k: 1)
p pd(1, 2, 3, k: 1)

def mix(*r, z) = [r, z]
p mix(1, 2)
p mix(1, a: 1, b: "t")

def ym(*r, z) = yield(r, z)
ym(1, a: 1) { |r, z| p [r, z] }

class C
  def initialize(*r, z); @v = [r, z]; end
  attr_reader :v
  def self.cm(*r, z) = [r, z]
end
p C.new(1, a: 1).v
p C.new(a: 1).v
p C.cm(1, a: 1)

class Y
  def initialize(*r, z); @v = [r, z]; yield self; end
  attr_reader :v
end
Y.new(1, a: 1) { |y| p y.v }

class S
  def m(*r, z) = [r, z]
end
class T < S
  def m(*r, z) = super
end
p T.new.m(1, a: 1)
p S.new.send(:m, 1, a: 1)

# a virtual call from the base class
class A
  def n(x, *r, y, z) = "a #{x} #{r.inspect} #{y} #{z.inspect}"
  def go
    puts n(1, 2, 3, a: 1)
    puts n(1, 2, a: 1)
  end
end
class B < A
  def n(x, *r, y, z) = "b #{x} #{r.inspect} #{y} #{z.inspect}"
end
A.new.go
B.new.go

# a **kwrest beside the post takes the hash, the post the last positional
class KA
  def kr(*r, z, **o) = "a #{r.inspect} #{z.inspect} #{o}"
  def go = puts(kr(1, 2, k: 3))
end
class KB < KA
  def kr(*r, z, **o) = "b #{r.inspect} #{z.inspect} #{o}"
end
KA.new.go
KB.new.go

# a poly receiver
class P
  def m(*r, z) = [:p, r, z]
end
class Q
  def m(*r, z) = [:q, r, z]
end
[P.new, Q.new].each do |o|
  p o.m(1, a: 1)
  p o.m(1, 2, a: 1)
  p o.m(1, "x" => 2)
end

# a poly class receiver
class K1
  def initialize(*r, z); @v = [:k1, r, z]; end
  attr_reader :v
  def self.cm(*r, z) = [:k1, r, z]
end
class K2
  def initialize(*r, z); @v = [:k2, r, z]; end
  attr_reader :v
  def self.cm(*r, z) = [:k2, r, z]
end
[K1, K2].each do |k|
  p k.cm(1, a: 1)
  p k.new(1, a: 1).v
end
