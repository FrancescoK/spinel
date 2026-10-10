# spinel: share
# spinel: gc-minor
# A reopening's proc form holds its parameters boxed. What it yields on, a
# String, a user object, an Array or a Hash, reaches a block typed for it.
class Pt
  def initialize(n) = (@n = n)
  def n = @n
end
class String
  def pm(a) = yield(a)
end
class Array
  def pm(a) = yield(a)
  def pb(a, &blk) = blk.call(a)
  def ps(&blk) = blk.call("s")
end
class Hash
  def pm(a) = yield(a)
end
p (+"ab").pm("s") { |v| v + "!" }
y = [3]
p y.pm(y) { |v| v << 4; v }
p y
p y.pm([7]) { |v| GC.start; v.size }
p y.pm(Pt.new(4)) { |v| GC.start; v.n }
p y.pb("s") { |v| v + "!" }
p y.ps { |v| v + "!" }
h = {a: 1}
p h.pm(h) { |v| v[:b] = 2; v }
p h.pm(Pt.new(5)) { |v| v.n }

# A String that is aliased and mutated is a handle in the default build too;
# a block typed for a plain String reads its live bytes, and a block typed
# for the handle reads the handle.
class Array
  def pu(a, b) = yield(a, b)
end
s = +"hello"
s << " world"
t = s
p (+"ab").pm("plain") { |v| v.size }
p (+"ab").pm(s) { |v| v.size }
p (+"ab").pm(s) { |v| v.upcase }
p y.pb(s) { |v| GC.start; v + "!" }
p t
p y.pu(+"x", +"y") { |a, b| GC.start; a + b }

# A Float held boxed rides the boxed side channel; Infinity and NaN do not
# raise while the argument slot is filled.
class String
  def pf(a) = yield(a)
end
class Array
  def pf(a) = yield(a)
end
p (+"ab").pf(Float::INFINITY) { |v| v }
p (+"ab").pf(0.0 / 0.0) { |v| v.nan? }
p [1].pf(Float::INFINITY) { |v| v > 1 }
