class K
  def initialize(x) = @x = x
  def plus = @x + "a"
end
require "ostruct"
src = "s".dup
n = [K.new("s".dup), OpenStruct.new(plus: src)]
v = [n[0].plus, n[1].plus]
v[1] << "!"
p v, src
