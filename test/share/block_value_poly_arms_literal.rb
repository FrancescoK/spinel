# A boxed receiver's call kept as a block's value (`map(&:text)` over a
# boxed Array) carries the String its method publishes, where another
# class's method of the name answers a literal, and where the classes the
# receiver can hold are not known (#9258)
class C
  def initialize = @s = +"a"
  def add(x) = (@s << x; self)
  def text = @s
end

class D
  def text = "d"
end

h = { a: [C.new, C.new], b: 1 }
ts = h[:a].map(&:text)
us = h[:a].map { |c| c.text }
h[:a][0].add("!")
p ts, us
p ts[0].equal?(us[0])
mixed = [C.new, D.new]
ms = mixed.map(&:text)
mixed[0].add("?")
p ms
