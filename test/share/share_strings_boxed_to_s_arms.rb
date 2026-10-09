# spinel: share
# spinel: gc-minor
# A String read through a boxed to_s and changed in place: each arm keeps
# its own answer. A member's String is the member's own, a fresh String
# is nobody else's, and a receiver that is itself a String answers itself.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
class Fresh
  def initialize(n) = (@n = n)
  def to_s = @n + "?"
  def n = @n
end
class Sub < Own
  def to_s = @n.upcase
end
def tidy(o)
  s = o.to_s
  s << "!"
  [s, o.to_s]
end
a = Own.new(+"a")
f = Fresh.new(+"f")
u = Sub.new(+"u")
b = +"b"
p tidy(a), tidy(f), tidy(u), tidy(b), a.n, f.n, u.n, b
p tidy(12), tidy(:sym), tidy([1]), tidy(1.5)
e = RuntimeError.new(+"boom")
p tidy(e), e.message
