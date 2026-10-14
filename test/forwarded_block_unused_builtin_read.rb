# a method forwarding its own block to an Array's, a Hash's or a String's
# read that takes none (`def size(*a, &b) = @a.size(*a, &b)`) answers the
# read, as CRuby does, which leaves the block unused: a forwarded splat is
# still checked against the read's own count

class W
  def initialize(a) = (@a = a)
  def size(*a, &b) = @a.size(*a, &b)
  def join(*a, &b) = @a.join(*a, &b)
  def length(&b) = @a.length(&b)
  def include?(x, &b) = @a.include?(x, &b)
end
w = W.new([3, 1, 2])
p w.size
p w.join
p w.join("-")
p w.length
p w.include?(1)
begin
  w.size(1)
rescue ArgumentError => e
  puts e.message
end
p [1, 2].size { }

class H
  def initialize(h) = (@h = h)
  def size(*a, &b) = @h.size(*a, &b)
  def key?(k, &b) = @h.key?(k, &b)
  def keys(&b) = @h.keys(&b)
end
h = H.new({a: 1, b: 2})
p h.size, h.key?(:a), h.keys

class S
  def initialize(s) = (@s = s)
  def length(*a, &b) = @s.length(*a, &b)
  def upcase(&b) = @s.upcase(&b)
  def start_with?(*a, &b) = @s.start_with?(*a, &b)
end
s = S.new("abc")
p s.length, s.upcase, s.start_with?("a")
