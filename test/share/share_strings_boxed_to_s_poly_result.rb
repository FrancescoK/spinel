# spinel: share
# spinel: gc-minor
# Another class answers to_s with a non-String, so the call is typed poly:
# a String receiver's own String is still the answer, not a copy of it.
class Own
  def initialize(n) = (@n = n)
  def to_s = (@n.size > 9 ? 5 : @n)
  def n = @n
end
def tidy(o)
  s = o.to_s
  s << "!"
  [s, o.to_s]
rescue => e
  e.class
end
a = Own.new(+"a")
p tidy(a), tidy(+"b"), tidy(3), a.n
