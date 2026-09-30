# A Struct, Data or plain object compared with an Array is unequal, in
# either order: Object#==, Struct#== and Array#== answer false for it. A
# class that defines its own == answers through it when it is the receiver.
S = Struct.new(:a)
class P; def initialize(x) = @x = x; end
class Q
  def initialize(x) = @x = x
  def ==(o) = o.is_a?(Array) && o == [@x]
end
D = Data.define(:a)
s = S.new(1)
p1 = P.new(1)
q = Q.new(1)
d = D.new(1)
ia = [1, 2]
sa = ["a"]
fa = [1.5]
pa = [1, "x"]
oa = [S.new(1)]
ea = []

p [s == [1], s != [1], [1] == s, [1] != s]
p [p1 == [1], p1 != [1], [1] == p1, [1] != p1]
p [q == [1], q != [1], [1] == q, [1] != q]
p [d == [1], d != [1], [1] == d]
p [s == ia, s == sa, s == fa, s == pa, s == oa, s == ea]
p [ia == s, sa == s, fa == s, pa == s, oa == s, ea == s]

# both operands are evaluated, once
$n = 0
def tick = ($n += 1; [1])
p [s == tick, tick == s, p1 == tick, tick != p1, $n]
p [S.new(1) == [1], [1] == S.new(1)]

# an object with a <=> and Comparable#== answers through it, an Array included
class V
  include Comparable
  def initialize(*a) = @a = a
  def parts = @a
  def <=>(o) = o.is_a?(Array) ? parts <=> o : (o.is_a?(V) ? parts <=> o.parts : nil)
end
v = V.new(1, 2)
p [v == ia, v != ia, v == [1], v == ea, ia == v, ia != v]

# an empty [] literal is an Array too
p [s == [], s != [], p1 == [], [] == p1, [] != s, d == [], q == []]

# a native class with its own == takes every operand
buf = IO::Buffer.new(4)
begin
  buf == [1]
rescue TypeError
  puts "TypeError"
end
p buf == buf

# the neighbours
p s == S.new(1), s == S.new(2)
p [s.eql?([1]), [1].eql?(s), s.equal?([1])]
