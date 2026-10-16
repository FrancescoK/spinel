# A parenthesized left operand of a boxed `||` is that operand: a String
# variable's or an ivar's handle is kept, not boxed as its bytes (#9258)
def pass(x) = x
class App
  def initialize(s) = @s = s
  def plain(v) = @s || v
  def par(v) = (@s) || v
  def bang(v) = (@s.upcase!) || v
end
[:plain, :par, :bang].each do |m|
  a = +"abc"
  y = pass(App.new(a).send(m, 1))
  y << "!"
  p [m, a, y.equal?(a)]
end
