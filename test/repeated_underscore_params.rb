# Ruby lets an underscore-prefixed name repeat in one parameter list whatever
# the kind of the repeat: a rest, a keyword rest or a block parameter as well as
# a required, optional or post one. Each repeat binds a slot of its own and the
# body reads the first, so a supplied argument never reaches the name. Only a
# repeated optional parameter's default assigns it (the first's local), so
# `def m(_a, _a = 5) = _a` answers 5 when called with one argument.
def a(_, *_) = :a
def b(_, **_) = :b
def c(_, &_) = :c
def d(*_, **_) = :d
def e(_, k: 1, **_) = :e
p a(1, 2), b(1, x: 2), c(1) { }, d(1, y: 2), e(1, z: 3)

# the body reads the first of each kind
def r1(_a, *_a) = _a
def r2(*_a, **_a) = _a
def r3(_a, **_a) = _a
def r4(*_a, &_a) = _a
def r5(_a, _b, _a) = _a
def r6(_a, **_a, &_a) = _a
p r1(1, 2, 3), r2(1, 2, x: 3), r3(1, y: 2), r4(1, 2) { }, r5(1, 2, 3), r6(4, z: 5) { }
p r2(1, 2, x: 3).size, r4(7) { }.size

# a repeated optional parameter's default assigns the first's local
def m(_a, _a = 5) = _a
def n(_a = 1, _a = 2) = _a
def o(_a, _b = _a, _a = 7) = [_a, _b]
def q(_a = 9, _b, _a) = _a
p m(1), m(1, 2), n, n(5), n(5, 6), o(1), o(1, 2), o(1, 2, 3), q(1, 2), q(1, 2, 3)

# a keyword parameter keeps its name; a later keyword rest or block repeat does not
def kw1(_k:, **_k) = _k
def kw2(_k: 1, **_k) = _k
def kw3(_k: 1, &_k) = _k
p kw1(_k: 7, a: 1), kw2, kw2(_k: 3, z: 1), kw3(_k: 3) { }

# the first is never read, a default has a side effect, a default of another type
def v1(_, _ = :d, *_, **_, &_) = :v1
def v2(_a, _a = (puts "default"; 8)) = 1
def v3(_a, _a = "x") = _a
class K
  def initialize(_a, _a = 5) = @v = _a
  attr_reader :v
end
p v1(1), v1(1, 2, 3, z: 1) { }, v2(1), v2(1, 2), v3(1), v3(1, 2), K.new(3).v, K.new(3, 4).v
def w(_a = 3, _b = 4, _a = _b + 1, _a = 0) = [_a, _b]
p w, w(1), w(1, 2), w(1, 2, 3), w(1, 2, 3, 4)

# a destructured name writes the same local
def s(_a, (_a, _b)) = _a
def t(_a, (_a, _a)) = _a
p s(1, [2, 3]), t(1, [2, 3])

# blocks and lambdas
p proc { |_x, _x| _x }.call(1, 2)
p proc { |_x, *_x| _x }.call(1, 2, 3)
p proc { |_x, _y, **_x| _x }.call(1, 2, z: 3)
p proc { |_x, (_x, _y)| _x }.call(1, [2, 3])
p proc { |_x, _x = 7| _x }.call(1)
p proc { |_x, _x = 7| _x }.call(1, 2)
p lambda { |_x, _x| _x }.call(1, 2)
p ->(_x, _x = 5) { _x }.call(1)
p ->(_x, *_x) { _x }.call(1, 2, 3)
p ->(_, *_) { :l }.call(1, 2)
p ->(_, &_) { :l }.call(1) { }
p proc { |_, (_, _)| :pr }.call(1, [2, 3])
p [[1, 2], [3, 4]].map { |_x, _x| _x }
p [[1, 2], [3, 4]].each_with_index.map { |_, _| :ew }
p({ a: 1 }.map { |_, _| :hm })

# a default that assigns an earlier parameter, in a proc, a lambda and
# define_method, plain and repeated
p proc { |a = 1, b = (a = 4)| [a, b] }.call, proc { |a = 1, b = (a = 4)| [a, b] }.call(9)
p ->(a = 1, b = (a = 4)) { [a, b] }.call, ->(a, b = (a = 4)) { [a, b] }.call(1)
p ->(_x = 1, _x = 3) { _x }.call
p proc { |_x = 1, _x = 3| _x }.call, proc { |_x = 1, _x = 3| _x }.call(9)
def unread(a, b = (a = 9)) = 1
p unread(1)
class D
  define_method(:dm1) { |a, b = (a = 4)| a }
  define_method(:dm2) { |a = 1, b = (a = 4)| a }
  define_method(:dm3) { |_a, _a = 4| _a }
  define_method(:dm4) { |_a = 1, _a = 4| _a }
end
d = D.new
p d.dm1(1), d.dm2, d.dm2(9), d.dm3(1), d.dm3(1, 2), d.dm4, d.dm4(9)

# a default whose closure assigns an earlier parameter
def cl1(a, b = (g = -> { a = 7 }; g.call; 0)) = [a, b]
def cl2(a, b = (g = proc { a = 7 }; g.call; 0)) = [a, b]
def cl3(a, b = (g = -> { a += 1 }; g.call; 0)) = [a, b]
def cl4(a, b = ([1].each { a = 9 }; 0)) = [a, b]
def cl5(_a, _a = (g = -> { _a = 6 }; g.call; 0)) = _a
class D
  define_method(:dm) { |a, b = (g = -> { a = 7 }; g.call; 0)| [a, b] }
end
p cl1(1), cl2(1), cl3(1), cl4(1), cl5(1), cl1(1, 2), D.new.dm(1), D.new.dm(1, 2)

# a bare super passes the first's slot, and nil for the repeat's own once its
# default has run, with or without a read of the name before it
class Par
  def g(*a) = a
  def j(*a) = a
  def r(*a) = a
  def s(*a) = a
end
class Chi < Par
  def g(_a, _a = 5) = super
  def j(_a = 1, _a = 2) = super
  def r(_a, _a = 5)
    x = _a
    [x, super]
  end
  def s(_a, _a = 5, *_a) = super
end
c = Chi.new
p c.g(1), c.g(1, 2), c.j, c.j(9), c.j(9, 8), c.r(1), c.r(1, 2), c.s(1), c.s(1, 2, 3)

# the same into a parent of fixed arity: the parent's slot takes the nil
class Fx
  def m(a, b) = [a, b]
  def o(a, b) = [a, b]
  def n(a, b = 3) = [a, b]
end
class Fy < Fx
  def m(a, b = nil) = super
  def o(_a, _a = 5) = super
  def n(_a, _a = 5) = super
end
f = Fy.new
p f.m(1), f.m(1, 2), f.o(1), f.o(1, 2), f.n(1), f.n(1, 2)

# the name can be read again after the call and a generated name is not taken
def u(_a, _a__dup1, _a, *_a) = [_a, _a__dup1]
p u(1, 2, 3, 4, 5)
