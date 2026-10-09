module Kernel
  def kmeth = 42
end
class Object
  def ometh(v = 1) = v + 1
end
class A; def initialize = (@x = 1); end
p A.new.ometh, A.new.kmeth, 3.ometh(4)
