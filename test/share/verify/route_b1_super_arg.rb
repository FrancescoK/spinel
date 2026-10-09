class A; def set(v) = (@a = v); def a = @a; end
class B < A; def set(v) = super; end
o = B.new
s = +"abc"
o.set(s)
s << "!"
p(o.a)
p s
