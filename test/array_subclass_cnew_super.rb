# `super` in an Array, Hash or String subclass's own `def self.new` is
# Class#new: with no initialize of the program to run, it builds what
# Array.new (Hash.new, String.new) builds from the same arguments, on a new
# instance of the receiving class.

class T < Array
  def self.new(*a) = super([42])
end
x = T.new(1, 2)
p x, x.class

class T2 < Array
  def self.new(n, v) = super
end
p T2.new(2, :z), T2.new(2, :z).class

class U < Array
  def self.new(n) = super
end
p U.new(2), U.new(2).class

class U2 < Array
  def self.new(n, &b) = super(n, &b)
end
p U2.new(2) { |i| i * 3 }

class U3 < Array
  def self.new(*a) = super(*a)
  def total = sum
  def self.make = new(3, 1)
end
u = U3.make
u << 5
p u, u.total, u.class, u.is_a?(Array)
p U3.new([7, 8]), U3.new

class E < Array
  def self.new(*a) = super()
end
p E.new(1), E.new(1).class

# through a class value
def build(k, *a) = k.new(*a)
p build(T, 5), build(E).class, [T, U3].map { |k| k.new.class }

class C < Array
  class << self
    def new(*a) = super(a.size)
  end
end
p C.new(:a, :b), C.new.class

class W < Array
  def self.new(*a)
    o = super(a.size, :w)
    o.instance_variable_set(:@n, a.size)
    o
  end
  attr_reader :n
end
w = W.new(1, 2, 3)
p w, w.n

# the class's own replace is not called
class R < Array
  def replace(x) = raise("no")
  def self.new(*a) = super([1])
end
p R.new

# with an initialize, Class#new runs it
class I < Array
  def initialize(a) = (super([a, a]); @tag = a)
  attr_reader :tag
  def self.new(a) = super(a * 2)
end
t = I.new(4)
p t, t.class, t.tag

class HD < Hash
  def self.new(*a) = super
end
p HD.new(3)[:x], HD.new.class

class HB < Hash
  def self.new = super { |h, k| h[k] = k.to_s * 2 }
end
hb = HB.new
p hb[:ab], hb, hb.class

class SS < String
  def self.new(*a) = super
  def shout = upcase + "!"
end
p SS.new, SS.new("yo").shout, SS.new("yo").class

class S1 < String
  def self.new(s) = super(s + "!")
end
p S1.new("hi"), S1.new("hi").class

# a `**` splat is left to Class#new
class KW < Array
  def self.new(**kw) = super(**kw)
end
p KW.new, KW.new.class
