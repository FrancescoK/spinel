# spinel: gc-stress
# A boxed receiver's attribute targets take their receivers before the right
# side, as a Struct's attribute targets do.
S2 = Struct.new(:a, :b)
SS = S2.new(0, 0)
class K; attr_accessor :x; end
class J; attr_accessor :x; end
def ss = (puts "ss"; SS)
def pk(i) = (puts "pk"; [K.new, J.new][i])
def rhs = (puts "rhs"; [1, 2])
ss.a, ss.b = rhs
pk(0).x, pk(1).x = rhs
