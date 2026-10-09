class A; def m = (y = +"a"; @k = y; y); end
class B < A; def m = super; end
b = B.new
r = b.m
r << "!"
p b.instance_variable_get(:@k)
