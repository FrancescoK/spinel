# An Enumerator over a String (each_char, each_line, each_byte) that is
# walked where it is made reads the String as it is there; one a name keeps
# reads it when it is walked. A change through another name before the walk
# is seen by both.
s = +"abc"
t = s
t << "d"
p s.each_char.to_a, s.each_byte.to_a.sum, s.each_line.first
p s.each_char.to_a.join.equal?(s), s.each_char.map(&:upcase).join

# the value of an attribute assignment, whose writer changes, replaces or
# keeps the String
class Grow
  attr_reader :a
  def initialize = (@a = +"init")
  def a=(v)
    @a = v
    v << "!"
  end
end
class Swap
  attr_reader :a
  def initialize = (@a = +"init")
  def a=(v)
    @a = v
    v.replace("RR")
  end
end
g = Grow.new
w = +"ab"
p (g.a = w).each_char.to_a, w, g.a.equal?(w)
w2 = Swap.new
x = +"xy"
p (w2.a = x).each_char.to_a, x, w2.a.equal?(x)
p (g.a = +"cd").each_char.to_a, g.a

# a kept Enumerator over the same String reads it when it is walked
u = +"ab"
e = u.each_char
u << "c"
p e.to_a
l = u.each_line
u << "\nd"
p l.to_a, l.next

# a lazy chain outlives the expression: it reads the String when it is walked
lz = u.each_char.lazy.map(&:upcase)
u << "e"
p lz.to_a, u.each_char.with_index.to_a

# one walked where it is made, beside a change made by its block
v = +"mn"
n = 0
r = v.each_char.map { |c| n += 1; v << "z" if n == 1; c }
p r, v
