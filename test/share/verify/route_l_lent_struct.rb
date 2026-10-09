def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
S = Struct.new(:v)
o = S.new(+"abc")
grow(o.v)
p o.v
