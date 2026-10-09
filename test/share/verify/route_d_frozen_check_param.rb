def f(x) = x.frozen?
s = +"a"; t = s; t << "b"; p f(s); s.freeze; p f(t)
