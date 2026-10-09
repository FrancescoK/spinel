class A; def set(x) = (@k = x); end
class B < A; def bang = @k << "!"; end
b = B.new
s = +"abc"
b.set(s)
b.bang
p s
