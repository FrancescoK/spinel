# A String read out of an Array whose Strings are shared, stored into an
# Integer Array, widens it as the String would (#9258)
s = +"src"
a = [1, 2]
a[1] = [s, nil].map { |x| x.to_s }[1]
s << "s"
p a
b = [1, 2]
b << [s, +"t"].map { |x| x }.first
s << "!"
p b
t = [s].map { |x| x }
e = []
e << t[0]
e << 3
p e
