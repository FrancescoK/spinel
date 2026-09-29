# A keyword passed nil binds nil when the call reads it back from a hash: a
# literal key beside a `**` (the sources merge into one hash) or a `**` of a
# hash that holds nil. An Integer or Float keyword param read the value
# boxed in the hash through the bare payload, so nil bound 0 or 0.0, while
# the same keyword without the `**` bound nil. Each method below is called
# one way only, so its param keeps its Integer or Float type.
def m1(k1: 70) = [k1]
def m2(k1: 70) = [k1]
def m3(k1: 70) = [k1]
def f1(k1: 1.5) = [k1]
def f2(k1: 1.5) = [k1]
def c1(k1: 70) = [k1]
def c2(k1: 70) = [k1]

h = nil
g = { k1: nil }
p m1(k1: nil, **nil)
p m2(k1: nil, **h)
p m3(**g, k1: nil)
p f1(k1: nil, **nil)
p f2(**g)
p method(:c1).call(k1: nil, **nil)
p send(:c2, k1: nil, **nil)

class A
  def self.m(k1: 70) = [self, k1]
  def self.n(k1: 70) = [self, k1]
  def d(k1: 70) = [:a, k1]
  def i(k1: 70) = [:i, k1]
end

class B < A
  def d(k1: 70) = [:b, k1]
  def i(k1: 70) = super(k1: nil, **nil)
end

class Q
  def self.cm(k1: 70) = [:q, k1]
end

class R
  def self.cm(k1: 70) = [:r, k1]
end

class P
  def initialize(k1: 70)
    @k1 = k1
  end

  attr_reader :k1
end

p B.method(:m).call(k1: nil, **nil)
p B.n(k1: nil, **nil)
[A.new, B.new].each { |o| p o.d(k1: nil, **nil) }
[Q, R].each { |o| p o.cm(k1: nil, **nil) }
p B.new.i
p P.new(k1: nil, **nil).k1
