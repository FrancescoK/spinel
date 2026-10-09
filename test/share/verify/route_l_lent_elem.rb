def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
a = [+"abc"]
grow(a[0])
p a
