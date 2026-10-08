# A String an UnboundMethod, a method define_method defines, a curried proc,
# or a Method or proc read out of a slot that holds other values appends to
# is the caller's String (#6179): the caller's variable becomes the shared
# handle and the call hands it over. Each append is 100 bytes, so a copy
# cannot pass by capacity; a method or proc that only reads keeps the plain
# String.
# spinel: gc-minor
X = "x" * 100
class C
  def m(t) = (t << X; nil)
  def r(t) = t.size
  define_method(:dm) { |t| t << X; nil }
  define_method(:dm2) { |a, t| t.concat(X); a }
  define_method(:dr) { |t| t.size }
end
def g(t) = (t << X; nil)

s = +"a"; C.instance_method(:m).bind_call(C.new, s); p s.size
s = +"a"; C.instance_method(:m).bind(C.new).call(s); p s.size
s = +"a"; um = C.instance_method(:m); um.bind(C.new).(s); p s.size
s = +"a"; p C.instance_method(:r).bind_call(C.new, s), s.size
s = +"a"; C.new.dm(s); C.new.method(:dm).call(s); p C.new.dm2(1, s), s.size
s = +"a"; p C.new.dr(s), s.size
f = ->(t, u) { t << u; nil }
s = +"a"; f.curry[s][X]; cu = f.curry; cu.(s).(X); p s.size
s = +"a"; m = [method(:g), 1][ARGV.size]; m.call(s); p s.size
s = +"a"; q = [proc { |t| t << X }, 1][ARGV.size]; q.call(s); q[s]; p s.size
fz = "fr".freeze
begin; C.instance_method(:m).bind_call(C.new, fz); rescue FrozenError => e; p e.class; end
begin; C.new.dm(fz); rescue FrozenError => e; p e.class; end
s = +"a\0b"; C.new.dm(s); p s.size, s.bytes.first(4)
