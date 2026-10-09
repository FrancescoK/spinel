def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
def mk = (@m ||= +"abc")
grow(mk)
p @m
