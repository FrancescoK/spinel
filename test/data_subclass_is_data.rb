# A subclass of a named Data class is itself a Data class: it inspects as
# #<data ...>, is frozen, and keeps with / deconstruct_keys / is_a?(Data).
D = Data.define(:x, :y) do
  def sum = x + y
end

class Y < D; end

y = Y.new(1, 2)
p y
puts y
p Y.new(x: 3, y: 4)
p y.to_h
p y == Y.new(1, 2)
p y.eql?(Y.new(1, 2))
p y.frozen?
p y.with(y: 5)
p y.deconstruct_keys([:x])
p Y.members
p Y.ancestors.include?(Data)
p y.is_a?(Data)
p y.is_a?(Struct)
p y.sum
case y
in {x:, y: 2} then p x
end

class W < D
  def initialize(x:, y: 10) = super(x: x + 1, y: y)
  def hi = "hi#{x}"
end
w = W.new(x: 4)
p w
p w.hi
p w.frozen?

class V < Y
  def to_s = "V(#{x}, #{y})"
end
v = V.new(7, 8)
p v
puts v
p v.with(x: 0)

class Z < Data.define(:a); end
p Z.new(3)
