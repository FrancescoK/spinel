# spinel: share
# spinel: gc-minor
# An arm answering a frozen literal: the change raises FrozenError, and the
# literal keeps one identity beside a member's String.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
class Lit
  def to_s = "lit"
end
def tidy(o)
  s = o.to_s
  s << "!"
  [s, o.to_s]
rescue FrozenError
  "frozen"
end
a = Own.new(+"a")
p tidy(a), tidy(Lit.new), tidy(Lit.new), Lit.new.to_s.equal?(Lit.new.to_s), a.n
