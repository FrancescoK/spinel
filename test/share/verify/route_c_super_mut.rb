s = +"abc"
t = s
class A; def m(x) = x << "!"; end; class B < A; def m(x) = super; end; B.new.m(s)
p s
p t
