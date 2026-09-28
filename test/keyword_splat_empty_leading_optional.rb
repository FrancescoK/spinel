# A required parameter after an optional (`def hh(a = 5, c)`) is funded
# first, and a default reading an earlier parameter (`def pd(a, b = a)`)
# reads it bound: an empty `**` is no argument into either, a non-empty
# one is one more positional Hash, and a splat binds them by the count it
# spreads, through every call path. So is a `**` after a splat or past
# the last parameter, and a splat binds a rest's posts and an inlined
# yielding initialize.

he = {}
hn = { k: 1 }

def hh(a = 5, c) = [a, c]
p hh(1, **he)
p hh(1, **hn)
p hh(1, **{})
p hh(1, **nil)
p hh(*[1])
p hh(*[], 1)
a1 = [1]
p hh(*a1)
p hh(*a1, 2)
begin
  hh(**he)
rescue ArgumentError => e
  p e.message
end
begin
  hh(*[1, 2, 3])
rescue ArgumentError => e
  p e.message
end

def pd(a, b = a) = [a, b]
p pd(1, **he)
p pd(1, **hn)
p pd(1, **{})
p pd(1, **nil)
p pd(*[], 1)
p pd(*a1)
p pd(*a1, 2)

def h3(a, b = 5, c) = [a, b, c]
p h3(1, 2, **he)
p h3(1, 2, **hn)
p h3(*[1, 2])

def pd3(a, b = a * 2, c = b + 1) = [a, b, c]
p pd3(1, **he)
p pd3(1, 5, **he)
p pd3(*[1])

# typed from the positionals as laid out without the hash
def hl(a = 5, c) = c + 1
p hl(1, **{})
def h3n(a, b = 5, c) = [a, b, c]
p h3n(1, 2, **nil)

def hk(a = 5, c, k: 0) = [a, c, k]
p hk(*[1])
p hk(*[1], k: 2)

def hr(a = 1, *r, c) = [a, r, c]
p hr(*[1, 2])
p hr(*[1, 2, 3])
def pr(a, b = a, *r) = [a, b, r]
p pr(1, **he)
p pr(*[1])

def hb(a = 5, c, &f) = [a, c, f.call]
p hb(1, **he) { 3 }

def fw(...) = pd(...)
p fw(1, **he)
def fs(*) = hh(*)
p fs(1)

def ym(a = 5, c) = yield(a, c)
p ym(1, **he) { |x, y| [x, y] }
p ym(1, **hn) { |x, y| [x, y] }
p ym(*[1]) { |x, y| [x, y] }
def yp(a, b = a) = yield(a, b)
p yp(1, **he) { |x, y| [x, y] }
p yp(*[], 1) { |x, y| [x, y] }

p [1, "s"].map { |v| hh(v, **he) }
p [1, "s"].map { |v| pd(v, **he) }

class W
  attr_reader :v
  def initialize(a = 5, c) = (@v = [a, c])
  def self.cm(a, b = a) = [a, b]
end
p W.new(1, **he).v
p W.new(1, **hn).v
p W.new(*[1]).v
p W.cm(1, **he)
p W.cm(*[], 1)

class Y
  attr_reader :v
  def initialize(a, b = a); @v = [a, b]; yield self; end
end
Y.new(1, **he) { |y| p y.v }
Y.new(1, **hn) { |y| p y.v }

class S
  def m(a = 5, c) = [a, c]
  def n(a, b = a) = [a, b]
end
class T < S
  def m(a = 5, c) = super
  def n(a, b = a) = super
end
p T.new.m(1, **he)
p T.new.n(1, **he)
p S.new.send(:m, 1, **he)
p S.new.send(:n, 1, **he)

# a default reading the receiver
class R
  attr_accessor :x
  def initialize = (@x = 9)
  def m(a = @x, c) = [a, c]
  def n(a, b = @x) = [a, b]
end
r = R.new
r.x = 4
p r.m(1, **he)
p r.n(1, **he)
p r.m(*[1])

# a virtual call from the base class
class A
  def q(a = 5, c) = [:a, a, c]
  def u(a, b = a) = [:a, a, b]
  def go(e) = [q(1, **e), u(1, **e), u(*[], 1)]
end
class B < A
  def q(a = 5, c) = [:b, a, c]
  def u(a, b = a) = [:b, a, b]
end
p A.new.go({})
p B.new.go({})
p B.new.go({ k: 1 })

# a poly receiver
class P
  def initialize = (@x = :p)
  def m(a = @x, c) = [:p, a, c]
  def n(a, b = a) = [:p, a, b]
end
class Q
  def initialize = (@x = :q)
  def m(a = @x, c) = [:q, a, c]
  def n(a, b = a) = [:q, a, b]
end
[P.new, Q.new].each do |o|
  p o.m(1, **he)
  p o.n(1, **he)
  p o.m(1, **hn)
  p o.n(1, **hn)
end

# a poly class receiver
class K1
  def self.cm(a = 5, c) = [:k1, a, c]
  def initialize(a, b = a); @v = [:k1, a, b]; end
  attr_reader :v
end
class K2
  def self.cm(a = 5, c) = [:k2, a, c]
  def initialize(a, b = a); @v = [:k2, a, b]; end
  attr_reader :v
end
[K1, K2].each do |k|
  p k.cm(1, **he)
  p k.new(1, **he).v
  p k.new(1, **hn).v
end

# a `**` after a splat, or past the last parameter
def opt(a = nil, b) = [a, b]
p opt(*[], 1, **hn)
p opt(*[], 1, **he)
def op2(a, b = nil) = [a, b]
p op2(*[], 1, **hn)
p op2(*[1], **he)
def g(a, b) = [a, b]
begin
  g(1, 2, **hn)
rescue ArgumentError => e
  p e.message
end
p g(1, 2, **he)
p g(*[1], **hn)
def rr(a, *rest) = [a, rest]
p rr(*[], **hn)
p rr(*[1], **hn)
p rr(*[1], **he)
S2 = Struct.new(:x, :y)
p S2.new(*[1], **he)
p S2.new(*[1], **hn)
D2 = Data.define(:x, :y)
p D2.new(*[1, 2], **he)
begin
  D2.new(*[1], **hn)
rescue ArgumentError => e
  p e.message
end

# a splat into a rest with posts
def pr(*r, z) = [r, z]
p pr(*[1, 2])
p pr(*[1])
a2 = [4, 5, 6]
p pr(*a2)
def pr3(x, *r, y, z) = [x, r, y, z]
p pr3(*[1, 2, 3, 4])
p pr3(1, *[2, 3], 4)
begin
  pr(*[])
rescue ArgumentError => e
  p e.message
end
p [[1], [2, 3]].map { |v| pr(*v) }

# a default reading the receiver, from a splat
class F
  def initialize = (@x = 9)
  def f(a, b = @x) = [a, b]
  def g(a, b) = [a, b]
  def pr(*r, z) = [r, z]
end
p F.new.f(*[], 1)
p F.new.f(*[1])
p F.new.pr(*[1, 2])
begin
  F.new.g(1, 2, **hn)
rescue ArgumentError => e
  p e.message
end
p F.new.send(:f, *[], 1)
class G < F
  def f(a, b = @x) = super
  def pr(*r, z) = super
end
p G.new.f(*[], 1)
p G.new.pr(*[1, 2])
class F2
  def initialize = (@x = 8)
  def f(a, b = @x) = [:f2, a, b]
  def g(a, b) = [:f2, a, b]
  def pr(*r, z) = [:f2, r, z]
end
[F.new, F2.new].each do |o|
  p o.f(*[], 1)
  p o.pr(*[1, 2])
  p o.g(1, 2, **he)
  begin
    o.g(1, 2, **hn)
  rescue ArgumentError => e
    p e.message
  end
end
class A3
  def initialize = (@x = 7)
  def s(*r, z) = [:a, r, z]
  def f(a, b = @x) = [:a, a, b]
  def q(a, b) = [:a, a, b]
  def go(e) = [s(*[1, 2]), f(*[], 1), (q(1, 2, **e) rescue :raised)]
end
class B3 < A3
  def s(*r, z) = [:b, r, z]
  def f(a, b = @x) = [:b, a, b]
  def q(a, b) = [:b, a, b]
end
p A3.new.go({})
p B3.new.go({ k: 1 })
def yy(*r, z) = yield(r, z)
p yy(*[1, 2]) { |x, y| [x, y] }
def yo(a = nil, b) = yield(a, b)
p yo(*[], 1, **hn) { |x, y| [x, y] }

# a splat into an inlined yielding initialize
class YI
  attr_reader :v
  def initialize(a, c); @v = [a, c]; yield self; end
end
YI.new(*[1, 2]) { |y| p y.v }
begin
  YI.new(1, 2, **hn) { }
rescue ArgumentError => e
  p e.message
end
class YO
  attr_reader :v
  def initialize(a = 5, c); @v = [a, c]; yield self; end
end
YO.new(*[1]) { |y| p y.v }
YO.new(*[1, 2]) { |y| p y.v }
class YR
  attr_reader :v
  def initialize(*r, z); @v = [r, z]; yield self; end
end
YR.new(*[1, 2]) { |y| p y.v }
YR.new(*[1], **hn) { |y| p y.v }
class YP
  attr_reader :v
  def initialize(a, b = a); @v = [a, b]; yield self; end
end
YP.new(*[1]) { |y| p y.v }
YP.new(*[], 1) { |y| p y.v }
