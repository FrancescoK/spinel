# A splat with an argument after it -- a later positional, or a keyword hash
# that is one more positional -- binds by a count only the run time knows,
# whatever else the parameter list holds: a rest, its posts, a `**kwrest`,
# an optional. Every path that binds a method's parameters reads the same
# layout (arg_layout), so each shape below runs through the direct call,
# `send`, an instance method, the virtual dispatch, a class method, `.new`
# into initialize, `super(...)`, a bare super, an inlined yielding method,
# a yielding initialize, forwarders and `Method#call`. A yield's splat
# beside other values gathers the same way, and a Struct or Data member list
# takes any splat operand with an array form, an empty `[]` or `nil`
# included.
# spinel: gc-minor
e = []
one = [1]
two = [2]

# the shapes, as direct calls
def r1(a, *r) = [a, r]
def k1(a, **kw) = [a, kw]
def o1(a = 51, *r) = [a, r]
def o3(a, b = 52, c = 53, *r) = [a, b, c, r]
def pk(*r, a, **kw) = [r, a, kw]
def ok(a, b = 52, **kw) = [a, b, kw]
def oo(a = 51) = [a]
def ro(a, b = 52, *r) = [a, b, r]
def op(a, b = 52, c) = [a, b, c]
def f2(a, b) = [a, b]
p r1(*[], 1), r1(*[], 1, 2), r1(*e, 1), r1(*one, z: 3), r1(*[1], *nil, 3)
p k1(*e, 1), o1(*e, 1), o3(1, *two, 3, 4, 5), ok(*one, 2), ro(*one, 3)
p pk(*[[1]]), pk(*[1], **{ z: 2 }), oo(*[], z: 1), f2(*[1], "x")
p op(1, *two, 3), op(nil, *two, 3)

# send, an instance method, a class method, initialize, forwarders
class C
  attr_reader :v
  def initialize(a = nil, *r) = (@v = [a, r])
  def m(a, *r) = [a, r]
  def mk(a, b = 52, **kw) = [a, b, kw]
  def self.cm(a = 51, *r) = [a, r]
end
p send(:r1, *[], 1), C.new.m(*e, 1), C.new.mk(*one, 2), C.cm(*e, 1)
p C.new(*[], 1).v, C.new.public_send(:m, *one, z: 3)
def fw(...) = r1(...)
def fa(*, **) = r1(*, **)
p fw(*[], 1), fa(*e, 1), method(:r1).call(*[], 1), method(:pk).call(*[[1]])

# the virtual dispatch, super(...) and a bare super
class V
  def m(a, *r) = [a, r]
  def run(s) = m(*s, 1)
end
class W < V
  def m(a, *r) = [r, a]
end
p V.new.run([]), W.new.run([]), V.new.run([0])
class Sup < C
  def m(e) = super(*e, 1)
end
class Z < C
  def m(a, *r) = super
end
p Sup.new.m([]), Z.new.m(*[], 1)

# an inlined yielding method, and a yielding initialize
def y1(a, *r) = yield([a, r])
def y2(a, b = 52, **kw) = yield([a, b, kw])
def y3(a = 1, b) = yield("#{a} #{b}")
p y1(*[], 1) { |x| x }, y2(*one, 2) { |x| x }, y3(5) { |x| x }
class Y
  attr_reader :v
  def initialize(a, *r) = (@v = [a, r]; yield)
end
class Yh
  attr_reader :v
  def initialize(opts) = (@v = opts; yield)
end
p Y.new(*[], 1) { }.v, Yh.new(k: 1) { }.v

# a yield's splat beside other values
def g1
  s = [1]
  yield(*s, 2)
end
def g2 = yield(*[1, 2], 3, **{ k1: 4 })
def g3 = yield(*[], 1, **{})
def g4 = yield(*[], [1, 2])
p g1 { |a = 51, b| [a, b] }, g2 { |a, b, c = 53, k1: 70| [a, b, c, k1] }
p g3 { |a, k1: 70| [a, k1] }, g4 { |a, b| [a, b] }, g4 { |a, *r| [a, r] }
p g4 { |a, k: 0| [a, k] }, g1 { |*r, a| [r, a] }

# Struct and Data members from a splat
S = Struct.new(:a, :b)
S1 = Struct.new(:a)
K = Struct.new(:a, keyword_init: true)
D = Data.define(:a, :b)
p S.new(*[]).to_a, S.new(1, *[]).to_a, S.new(*[], 1).to_a, S.new(*nil).to_a
p S.new(*5).to_a, S1.new(*[]).to_a, K.new(*[]).to_a, S.new(*[], 1, 2).to_a
p D.new(*[], 1, 2).to_h, D.new(1, *[], 2).to_h
begin
  K.new(*[1])
rescue ArgumentError => ex
  puts "ArgumentError: #{ex.message}"
end
