def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
src = [+"abc"]
src.each { |x| grow(x) }
p src
