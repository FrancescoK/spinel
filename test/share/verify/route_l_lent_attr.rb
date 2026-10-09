def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
class K; attr_accessor :v; end
o = K.new; o.v = +"abc"
grow(o.v)
p o.v
