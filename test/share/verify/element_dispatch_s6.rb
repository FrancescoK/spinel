class K
  def initialize(x) = @x = x
  def plus = @x + "a"
end
class N
  def initialize(x) = @x = x
  def plus = yield(@x)
end
src = "s".dup
n = [K.new("s".dup), N.new(src)]
v = [n[0].plus, n[1].plus { |z| z }]
v[1] << "!"
p v, src
