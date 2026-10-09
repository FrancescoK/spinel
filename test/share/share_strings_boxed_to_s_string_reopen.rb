# spinel: share
# spinel: gc-minor
# String#to_s reopened to change self before answering it: the receiver
# that is a String runs the override, and the member's String stays its own.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
class String
  def to_s = (self << "~"; self)
end
def tidy(o)
  s = o.to_s
  s << "!"
  [s, o.to_s]
end
a = Own.new(+"a")
b = +"b"
p tidy(a), tidy(b), a.n, b
