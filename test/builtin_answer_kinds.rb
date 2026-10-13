# A builtin call answers by kind (#8837): a comparison, a count, a
# conversion or a predicate answers a scalar and keeps none of its
# operands, and an element read answers the receiver's elements. A block
# given to either still takes the receiver's elements, so a call on what
# the read answers, or on the block's parameter, reaches every class.
class Lamp
  def initialize(w) = @w = w
  def on? = @w > 1
  def w = @w
  def name = "lamp#{@w}"
end

class Fan
  def initialize(w) = @w = w
  def on? = false
  def w = @w
  def name = "fan#{@w}"
end

items = [Lamp.new(2), Fan.new(5), Lamp.new(1)]
p items.count { |x| x.on? }
p items.any? { |x| x.name == "fan5" }
p items.size == 3

p items.first.name
p items.last.name
p items[1].name
p items.at(1).name
p items.max { |a, b| a.w <=> b.w }.name
p({ k: [Fan.new(9)] }.dig(:k, 0).name)
h = { lamp: Lamp.new(4), fan: Fan.new(6) }
p h[:fan].name

stack = [Fan.new(7), Lamp.new(8)]
p stack.pop.name
p stack.shift.name
