# A push through a receiver-less reader types the array the ivar holds,
# whichever class writes it.

module M
  def items; @items ||= []; end
end
class K
  include M
  def add(x) = items << x
end
k = K.new
k.add("a"); k.add("b")
p k.items
p k.items.map(&:upcase)

class L
  attr_accessor :list
  def add(x) = list << x
end
l = L.new
l.list = []
l.add("s")
p l.list

class Base
  def initialize; @vals = []; end
  attr_reader :vals
end
class Sub < Base
  def put(x) = vals << x
end
s = Sub.new
s.put("z"); s.put("w")
p s.vals
p s.vals.map(&:upcase)

class Lazy
  def things; @things ||= load; end
  def load; []; end
  def add(x) = things << x
end
z = Lazy.new
z.add(:q)
p z.things
