def f(s, _) = s.bytesize
b = +"abc"
c = b
p f(b, c << "xyz")
