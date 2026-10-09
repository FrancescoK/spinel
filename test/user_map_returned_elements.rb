# A user class's own map or collect answers what its body returns, not the
# values of its block, so a String it returns stays the String it holds:
# appending to an element of the answer changes that String.
class Bag
  def initialize(s)
    @items = [s, +"b"]
  end
  def map
    @items.each { |x| yield x }
    @items
  end
end
class Box
  def initialize(s) = @s = s
  def collect = [@s]
end
s = +"a"
w = +"w"
r = Bag.new(s).map { |x| w }
r[0] << "!"
p [s, w]
t = +"t"
r2 = Bag.new(t).map { |x| x.size }
r2[0] << "?"
p t
u = +"u"
r3 = Box.new(u).collect { 5 }
r3[0] << "#"
p u
k = [+"k"]
r4 = k.map { |x| x }
r4[0] << "%"
p k
