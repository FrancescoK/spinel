# A's initialize keeps the caller's s in @k, and B's bang appends to the
# same @k, so s changes. The subclass's @k held a copy and s stayed "abc":
# refused, not compiled wrong.
class A
  def initialize(x) = (@k = x)
end
class B < A
  def bang = @k << "!"
end
s = +"abc"
B.new(s).bang
p s
