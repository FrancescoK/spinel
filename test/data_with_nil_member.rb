# Data#with stores what it is given, nil included, and keeps the nil of a
# member it leaves as it was (#8508).
Row = Data.define(:a)
p Row.new(1).with(a: nil).to_h
P = Data.define(:x, :y)
q = P.new(x: 1, y: "s")
r = q.with(y: nil)
p r, r.y, q
S = Struct.new(:n)
p S.new(3).n
p Row.new(2).with(a: 5)
Q = Data.define(:u, :w)
z = Q.new(u: nil, w: 1)
p z.with(w: 2), z.with(u: 3).with(w: nil)
f = Data.define(:g)
p f.new(1.5).with(g: nil)
p Row.new(1).with(a: "s")
