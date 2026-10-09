def grow0(b) = (b << "x"; b.size)
def grow(b) = (grow0(b); b << "y"; b.size)
def grow2(a, b) = (grow0(a); b << "2"; a.size + b.size)
s = +"abc"
a = [s]
grow(a[0])
p a, s
