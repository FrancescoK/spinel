class A; def set(x) = (@k = x); end
class B < A; end
b = B.new
s = +"abc"
b.set(s)
b.instance_variable_get(:@k) << "!"
p s
