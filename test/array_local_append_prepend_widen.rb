# Array#append / #prepend are exact aliases for #push / #unshift. Pushing or
# prepending a value a typed-array local cannot hold (e.g. nil onto an int
# array) must widen the local to a poly array, same as #push / #unshift --
# previously append/prepend were missing from the widening check, so the
# value silently lowered through the typed setter instead (nil -> 0).
# spinel: decisions
a = [1, 2]
a.append(nil)
p a                                   #=> [1, 2, nil]

b = [1, 2]
b.prepend(nil)
p b                                   #=> [nil, 1, 2]

c = [1, 2]
c.append(3, nil)
p c                                   #=> [1, 2, 3, nil]

d = [1, 2]
d.prepend(nil, 3)
p d                                   #=> [nil, 3, 1, 2]

e = [1, 2]
e.append("x")
p e                                   #=> [1, 2, "x"]

f = [1, 2]
f.push(3, nil)
p f                                   #=> [1, 2, 3, nil]

puts "done"
