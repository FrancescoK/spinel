# uniq! on a mixed Array keeps each value's first occurrence in order, by
# eql? (1 and 1.0 both stay), and answers nil when nothing was removed. The
# arrays here are mostly duplicates: long runs of them, interleaved kinds,
# nil and nested Arrays, and a user class with its own eql? and hash.
class Key
  attr_reader :k
  def initialize(k) = @k = k
  def eql?(o) = o.is_a?(Key) && o.k == k
  def hash = k.hash
  def inspect = "K#{k}"
end

vals = [1, 1.0, "a", :a, nil, [1, 2], 2, "b", 2.0, [1, 2], :b]
a = (0...3000).map { |i| vals[(i * 7) % vals.size] }
r = a.uniq!
p r.equal?(a), a.size, a
b = [nil] * 500 + [1] * 500 + ["x"] * 500 + [nil, 1, "x", 1.0]
p b.uniq!, b.uniq!
c = (0...2000).map { |i| Key.new(i % 13) }
c.uniq!
p c.size, c.first(4), c.last
d = (0...40).map { |i| i.even? ? i / 2 : "s#{i % 5}" }
p d.uniq!, d.size
e = [3, "q", 3.0, nil]
p e.uniq!
