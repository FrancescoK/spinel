# A program class with its own find_index: a builtin find_index(v) that
# misses answers nil, not a TypeError.

class Box
  def find_index(x) = :mine
end
p Box.new.find_index(1)

m = [1, "a"]
p m.find_index(9)
p m.find_index("a")
p [1.5, nil].find_index(2.5)
p %w[a b].find_index("z")
p [1, 2].find_index(7)
h = {a: 1}
p h.find_index([:b, 2])
p h.find_index([:a, 1])
def go(o) = o.find_index(7)
p go([1, 2])
p go([1, "x"])
p go({7 => 1})
r = m.find_index(9)
p r.nil?
p (m.find_index(9) || -1) + 1
x = m.find_index("a")
p x + 1 if x
