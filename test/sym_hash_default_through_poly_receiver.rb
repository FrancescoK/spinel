# A Hash.new("") read by a Symbol through a receiver that may also be another
# class answers the default on a miss.
class Bag
  def [](k) = "bag:#{k}"
end

def show(t, k)
  t[k]
end

h = Hash.new("")
h[:a] = "x"
p show(h, :a)
p show(h, :b)
p show(Bag.new, :c)
