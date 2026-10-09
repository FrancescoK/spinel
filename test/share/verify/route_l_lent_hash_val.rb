def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
h = {k: +"abc"}
grow(h[:k])
p h
