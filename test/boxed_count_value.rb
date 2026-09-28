# count(x) on a Hash, a Range or an Enumerator read out of a container
# counts the items equal to x, as on a typed receiver: a Hash's [key,
# value] pairs, a Range's members, an Enumerator's values.
h = [{ a: 1, b: 2 }, 0][0]
p [h.count([:a, 1]), h.count([:a, 2]), h.count(:a)]
r = [(1..10), 0][0]
p [r.count(3), r.count(11)]
p [("a".."e"), 0][0].count("c")
e = [[1, 2, 2, 3].each, 0][0]
p e.count(2)
p [{ x: 1, y: 1 }.each, 0][0].count([:y, 1])
a = [[1, 1, 2], 0][0]
p a.count(1)
p ["hello", 0][0].count("l")
