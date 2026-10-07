# An Enumerator read out of a mixed Array answers none?, any?, all?, one?,
# min and max over the items it yields, as a typed one does; the predicates
# had counted nothing and answered as if it were empty, and min / max raised
# NoMethodError.
e = [[3, 1, 2].each, 1][0]
p e.none?
p e.any?
p e.all?
p e.one?(3)
p e.any? { |x| x > 2 }
p e.none? { |x| x > 5 }
p e.min
p e.max
p e.next
p e.any?(1)
p e.next
z = [[].each, 1][0]
p z.none?
p z.any?
p z.min
w = [%w[a b].each_with_index, 1][0]
p w.any? { |s, i| i == 1 }
p w.max
g = [Enumerator.new { |y| y << 5; y << 9 }, 1][0]
p g.min
p g.max
p g.any? { |x| x > 8 }
p g.all?(Integer)
