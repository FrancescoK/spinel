# Data#with returns a copy of a Data instance with the given members overridden
# and the rest carried over. Only Data classes (Data.define) have #with.
P = Data.define(:x, :y)
a = P.new(x: 1, y: 2)

b = a.with(x: 9)
p [b.x, b.y]          # [9, 2]
p [a.x, a.y]          # [1, 2]  -- original is unchanged

c = a.with(x: 10, y: 20)
p [c.x, c.y]          # [10, 20]

d = a.with             # no overrides -> the receiver itself
p [d.x, d.y]          # [1, 2]

# string and mixed members.
Person = Data.define(:name, :age)
e = Person.new(name: "bob", age: 5)
f = e.with(age: 6)
p [f.name, f.age]     # ["bob", 6]
g = e.with(name: "ann")
p [g.name, g.age]     # ["ann", 5]
