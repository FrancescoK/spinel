# A boxed to_s with an arm answering nil is not a String route: the change
# to the other arms' String stays refused until the nil arm has a carrier.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
class Nope
  def to_s = nil
end
def tidy(o)
  s = o.to_s
  return "nil" if s.nil?
  s << "!"
  s
end
a = Own.new(+"a")
p tidy(a), tidy(Nope.new), a.n
