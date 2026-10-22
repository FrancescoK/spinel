# A Hash or Range reopen's own method of an Enumerable name that Spinel
# serves through the pair array or the member array (uniq, minmax, sort,
# find, sum, take, ...) is the call's target.
class Hash
  def uniq; "my-uniq"; end
  def minmax; "my-minmax"; end
  def sort; "my-sort"; end
  def find(*a); "my-find"; end
  def tally; "my-tally"; end
end

class Range
  def sum; "my-sum"; end
  def reverse_each; "my-reverse_each"; end
  def min(n); "my-min"; end
  def take(n); "my-take"; end
  def group_by; "my-group_by"; end
end

h = {a: 1, b: 2}
puts h.uniq
puts h.minmax
puts h.sort
puts h.find
puts h.tally
p h.select { |k, v| v > 1 }.to_a
p h.max_by { |k, v| v }

r = (1..3)
puts r.sum
puts r.reverse_each
puts r.min(2)
puts r.take(2)
puts r.group_by
p r.to_a
p r.select(&:odd?)

def via_method(h, r)
  [h.uniq, r.take(1)]
end
p via_method({x: 1}, (4..6))

class Hash
  def store(k, v) = :my_store
end
h2 = {a: 1}
p h2.store(:b, 2)
p h2.size
