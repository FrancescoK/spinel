# spinel: gc-minor
# A lazy chain held in a local over a String iterator's Enumerator runs its
# source once, where the local is written, and the Enumerator reads the String
# when the chain is forced: the value of an attribute assignment or a Struct
# member's is assigned there, and a change in place before the force shows.

class C
  attr_accessor :a
  def initialize = (@a = +"init")
end
o = C.new
s = +"abc"
l1 = (o.a = s).each_char.lazy.map(&:upcase)
s << "d"
p l1.to_a
S = Struct.new(:a)
so = S.new(+"init")
s = +"abc"
l2 = (so.a = s).each_char.lazy.map(&:upcase)
s << "d"
p l2.to_a

# changed through the field it was assigned to, and read before the force
o = C.new
s = +"abc"
l3 = (o.a = s).each_char.lazy.map(&:upcase)
p o.a
o.a << "d"
p l3.to_a, l3.first(2), o.a.equal?(s)
class W
  def initialize = (@a = +"init")
  def a = @a
  def a=(v)
    @a = v
  end
end
w = W.new
s = +"abc"
l4 = (w.a = s).each_char.lazy.map(&:upcase)
w.a << "d"
p l4.to_a

# a source made by a call runs once; a local rebound after it is not read
$n = 0
def src
  $n += 1
  +"abc"
end
l5 = src.each_char.lazy.map(&:upcase)
p $n, l5.first(2), l5.to_a, $n
s = +"ab"
l6 = s.each_char.lazy.map(&:upcase)
s = +"zz"
p l6.to_a
s = +"abc"
l7 = s.each_char.lazy.map(&:upcase)
s << "d"
p l7.to_a, l7.to_a

# a view of a String changed in place, then rebound
s = +"abcd"
t = s
l8 = s.each_char.each_slice(2).lazy.map(&:join)
t.replace("1234")
p l8.to_a
s = +"zz"
p l8.to_a
