# An Enumerator over the value of an assignment whose writer changes,
# replaces or freezes the String it is handed, or keeps a copy of it, is an
# Enumerator over that String: kept, it reads the String when it is walked;
# walked where it is made, it reads the String as the writer left it.

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
class Copy
  attr_reader :a
  def initialize = (@a = +"init")
  def a=(v)
    @a = v.dup
    v << "?"
  end
end
class Frz
  attr_reader :a
  def initialize = (@a = +"init")
  def a=(v)
    @a = v
    v.freeze
  end
end

o1 = Grow.new
s = +"ab"
e = (o1.a = s).each_char
p e.to_a, s
s << "z"
p e.next, e.size
p (o1.a = (+"cd")).each_char.to_a

o2 = Swap.new
s = +"ab"
e = (o2.a = s).each_char.with_index
s << "c"
p e.to_a, o2.a
s2 = +"xy"
p (o2.a = s2).each_char.to_a, s2

o3 = Copy.new
s = +"ab"
l = (o3.a = s).each_char.lazy.map(&:upcase)
s << "c"
p l.to_a, o3.a
s3 = +"mn"
p (o3.a = s3).each_byte.to_a, o3.a

o4 = Frz.new
s = +"ab"
e = (o4.a = s).each_char
p e.next, s.frozen?
p (o4.a = (+"pq")).each_char.to_a
begin
  s << "x"
rescue FrozenError => ex
  p ex.class
end
p e.to_a
