# `...` forwards keywords as keywords, so a `**nil` method reached through
# it refuses them as a direct call does: "no keywords accepted", not a wrong
# count, and never a positional Hash bound into an optional. A Hash passed
# positionally stays a positional, and an empty `**` passes nothing to
# refuse. A forwarder choosing between a `**nil` target and one taking
# keywords refuses them only on the `**nil` branch.

def t
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

def m(a, **nil) = a
def mo(a, b = 7, **nil) = [a, b]
def none(**nil) = :none
def w(...) = m(...)
def wo(...) = mo(...)
def wn(...) = none(...)
def wl(a, ...) = m(a, ...)
def v(...) = w(...)
def y(a, **nil) = yield(a)
def wy(...) = y(...)
def kw(a, **k) = [a, k]
def pick(c, ...) = c ? m(...) : kw(...)

t { w(1, z: 3) }
t { w(1) }
t { w(1, **{}) }
h = { "s" => 4 }
t { w(1, **h) }
e = {}
t { w(1, **e) }
t { wo(1, z: 3) }
t { wo(1, 2) }
t { wo(1, { z: 3 }) }
t { wn(z: 1) }
t { wn }
t { wl(1, z: 3) }
t { wl(2) }
t { v(1, z: 3) }
t { v(3) }
t { wy(1, z: 3) { |x| x + 1 } }
t { wy(1) { |x| x + 1 } }
t { pick(true, 1, z: 3) }
t { pick(false, 1, z: 3) }
t { pick(true, 2) }
t { send(:w, 1, z: 3) }
t { method(:w).call(1, z: 3) }
t { method(:wo).call(4) }

class P
  def initialize(a, **nil) = (@a = a)
  def a = @a
  def k(a, **nil) = a
  def yk(a, **nil) = yield(a)
end
class Q < P
  def initialize(...) = super(...)
  def k(...) = super(...)
end
class R < P
  def k(...) = super
  def yk(...) = super(...)
end
class S < P
  def self.make(...) = new(...)
end
t { Q.new(1, z: 3).a }
t { Q.new(2).a }
t { Q.new(0).k(1, z: 3) }
t { Q.new(0).k(3) }
t { R.new(0).k(1, z: 3) }
t { R.new(0).k(4) }
t { S.make(1, z: 3).a }
t { S.make(5).a }
r = R.new(0)
begin
  p r.yk(1, z: 3) { |x| x + 1 }
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
p r.yk(6) { |x| x + 1 }
