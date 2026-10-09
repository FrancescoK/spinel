class A; def set(v) = (@a = v); def a = @a; end
class B < A; def set(v) = super(v); end
o = B.new
s = +"abc"
o.set(s)
(o.a) << "?"
p s
p(o.a)
