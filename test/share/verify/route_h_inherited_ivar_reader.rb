class A; attr_reader :k; end
class B < A; def set(x) = (@k = x); end
b = B.new
s = +"abc"
b.set(s)
b.k << "!"
p s
