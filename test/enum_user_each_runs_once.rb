# A user class that includes Enumerable and is read out of a mixed slot has
# its #each walked once per call of an Enumerable method that answers an
# Enumerator or takes a count (reverse_each, each_entry, take, first(n),
# each_cons, each_slice, drop, last, min(n), max(n)): the receiver check and
# the walk each read its elements, so each ran twice, and each_cons /
# each_slice more than that.

class Bag
  include Enumerable
  def each
    puts "each ran"
    yield 3
    yield 1
    yield 2
  end
end
v = [Bag.new, 1][0]
p v.reverse_each.to_a
p v.each_entry.to_a
p v.take(1)
p v.first(2)
p v.each_cons(2).to_a
p v.each_slice(2).to_a
p v.drop(1)
p v.min(2)
p v.max(2)
p v.map.to_a
p v.select.to_a
