class A
  def initialize(x) = (@k = x)
end
class B < A
  def bang = @k << "!"
end
s = +"abc"
B.new(s).bang
p s
