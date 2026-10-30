# A boxed walk over each Array kind reads what the Array holds
# The walk's length and element reads answer a PolyArray, an Integer Array
# and a Float Array inline; the other kinds (Symbols, Hashes, Ranges,
# Enumerators) are read as before. Nil gaps, an empty Array, and an Array
# the block grows or shrinks read as CRuby reads them.

def box(x) = [x, 1].first

def walk(v)
  out = []
  v.each { |x| out << x }
  out
end

p walk(box([1, 2, 3]))
p walk(box([1.5, 2.5]))
p walk(box([1, "a", :b, nil, 2.0]))
p walk(box([]))
p walk(box(%i[x y]))
p walk(box({ a: 1 }))
p walk(box(1..3))

ints = [1, 2]
ints[4] = 5
p walk(box(ints))
flts = [1.0]
flts[2] = 3.0
p walk(box(flts))

grow = box([1, 2, 3])
seen = []
grow.each { |x| seen << x; grow << x * 10 if x < 3 }
p seen
shrink = box([1, 2, 3, 4, 5])
seen = []
shrink.each { |x| seen << x; shrink.pop if x == 2 }
p seen

sum = 0
box([[1, 2], [3]]).each { |row| box(row).each { |x| sum += x } }
p sum
