class A; def m = (y = +"a"; @k = y; y); def k = @k; end
class B < A; def m = super; end
b = B.new
b.m << "!"
p b.k
