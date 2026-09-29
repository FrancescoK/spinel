# A method's parameters take their types from what the call's positional
# layout funds each of them from (arg_layout): the argument it names, an
# element of a splat, the keyword hash as one more positional, or, where
# the count is the run time's, whichever gathered value may land there.
# Inference typed them by its own index rules, so a post fed by a trailing
# splat was typed from the positional at its index, and a parameter a
# gathered keyword hash may reach kept a type that cannot hold a Hash: the
# answer read a String's pointer as a number, bound the hash elsewhere, or
# the C did not build. Each shape runs through the direct call, `.new` into
# initialize, a class method, an instance method, `send` and `super(...)`,
# with an Integer call ahead that types the parameters first, and
# `UnboundMethod#bind_call` binds as a direct call, where it put argument k
# into parameter k - 1, and a keyword hash into a `**kwrest` whole.

def post2(a, *r, b, c) = [a, r, b, c]
p post2(1, 2, 3, 4)
p post2(1, *["x", :y])
p post2(2.5, 2.5, *[1, :y])
p post2("s", *[1], k: :y)
p post2(*[:m, 3.5], *["s"], k: "s")
[-> { post2(*[2.5], k: :y) }, -> { post2(*[], 1, k: nil) }].each do |c|
  p c.call
rescue ArgumentError => e
  p e.message
end

# the posts a keyword hash and a splat fill, typed Integer by a call ahead
def pc(a, *r, b, c) = [a, r, b, c]
p pc(1, 2, 3, 4)
p pc("s", *[1], k: :y)

# a post fed from the end, a lone optional ahead of it
def pr1(a, *r, b) = [a, r, b]
p pr1(1, 2)
p pr1(1, *["x"])
p pr1(*["x", 2.5])

# a keyword hash the gather carries, into a parameter a default types
def optr(a, b = :d, *r) = [a, b, r]
p optr(*["s"], "t", k: "u")
p optr(*["s"], "s", k: "s")
def optp(a, b = :d, *r, c) = [a, b, r, c]
p optp(*[1], 1, k: nil)

# a gathered keyword hash is the last argument, so it lands in the last post
# whatever the index of the splat before it, and never in a parameter the
# ones funded from the end always leave to a splat's element
def lp(*r, q) = [r, q]
v = [2]
p lp(1, 1, *v, k: 3), lp(5)
def lp2(a, *r, q, s) = [a, r, q, s]
p lp2(1, 2, 3, 4, *v, k: 3), lp2(1, 2, 3)
def up(a, *r, q) = q.upcase
p up("x", "y")
begin
  p up("a", "b", "c", *[], k: 3)
rescue NoMethodError => e
  p e.class
end
def lo(a = 1, b) = [a, b]
p lo(5), lo(*v, k: 3), lo(*[], k: 4)
def lk(a, *r, q) = [a, r, q]
p lk(1, 2), lk(1, *v, **{k: 3}), lk(1, *v, **{})
class K2
  def self.cm(*r, q) = [r, q]
end
p K2.cm(5), K2.cm(1, 1, *v, k: 3)

# a parameter a leading optional or a `**` leaves to one source keeps its type
def lead(a = 5, b) = [a, b]
p lead("s")
p lead(*[1, "t"])
def dsp(a, b = nil) = [a, b]
h = { k: 1 }
e = {}
p dsp(1, **h), dsp(2, **e)

# the same, through the other call paths
class K
  def initialize(a, *r, b, c) = (@v = [a, r, b, c])
  def v = @v
  def self.cm(a, *r, b, c) = [a, r, b, c]
  def im(a, *r, b, c) = [a, r, b, c]
  def ko(a, b = :d, *r) = [a, b, r]
end
p K.new(1, 2, 3, 4).v, K.new(1, *["x", :y]).v
p K.cm(1, 2, 3, 4), K.cm(1, *["x", :y])
k = K.new(0, 0, 0)
p k.im(1, 2, 3, 4), k.im(1, *["x", :y])
p k.send(:im, 1, *["x", :y])
p k.ko(1), k.ko(*["s"], "t", k: "u")

class P
  def m(a, *r, b, c) = [a, r, b, c]
end
class Q < P
  def m(a) = super(a, *["x", :y])
end
p P.new.m(1, 2, 3, 4), Q.new.m(1)

# UnboundMethod#bind_call binds its arguments as a direct call does
class B
  def op(a = 5, b) = [a, b]
  def w(x, **o) = [x, o]
  def d(x, y = 2, **o) = [x, y, o]
  def h(opts) = opts
end
p B.instance_method(:op).bind_call(B.new, "s")
p B.instance_method(:w).bind_call(B.new, 1, q: 2), B.instance_method(:w).bind_call(B.new, 1)
p B.instance_method(:d).bind_call(B.new, 1, z: 3), B.instance_method(:h).bind_call(B.new, x: 1)
p B.new.op(1, 2)

# `raise Cls, msg` is `Cls.new(msg)`: the message goes where a call of one
# argument puts it, into b past a leading optional
class LayoutErr < StandardError
  def initialize(a = 5, b) = super("#{a}/#{b}")
end
[-> { raise LayoutErr, "s" }, -> { raise LayoutErr, 7 }, -> { k = [LayoutErr][0]; raise k, "t" }].each do |l|
  l.call
rescue LayoutErr => e
  p e.message
end
