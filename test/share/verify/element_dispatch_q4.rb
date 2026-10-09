class K
  def initialize(x) = @x = x
  def plus = @x + "a"
end
module M; def plus = @x; end
class N; prepend M; def initialize(x) = @x = x; def plus = @x + "z"; end
src = "s".dup
n = [K.new("s".dup), N.new(src)]
v = [n[0].plus, n[1].plus]
v[1] << "!"
p v, src
