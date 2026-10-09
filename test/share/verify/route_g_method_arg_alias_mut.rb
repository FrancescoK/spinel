def f(a, b) = (b << "!"; a)
s = +"x"
r = f(s, s)
p r, s, r.equal?(s)
