class A
  def initialize(x) = (@k = x)
end
class B < A
  def k = @k
end
s = +"abc"
b = B.new(s)
b.k << "!"
p s
