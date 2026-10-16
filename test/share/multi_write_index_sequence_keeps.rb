# A multiple write into the elements of a general Array or Hash keeps the
# String a parenthesized sequence or a conditional ends in, and holds a new
# String as its handle (#9258)
s = +"abc"
f = [0, 0]
f[0], f[1] = (s << "f"; s), (s << "F"; s)
p f, s
g = [0, 0, 0]
h = { a: 1 }
g[0], g[1], h[:a] = (s; s), [+"x" * 3, +"y"].join, (s << "!"; s)
s << "?"
p g, h
k = [nil, nil]
c = ARGV.size
k[0], k[1] = (c > 3 ? +"q" : s), (+"z") * 2
k[1] << "#"
p k
