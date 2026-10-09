def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
$s = +"abc"
t = $s
grow(t)
p $s, t
