# A builtin call with no block answers by kind (#8837): a comparison, a
# count, a conversion or a predicate answers a scalar and keeps none of
# its operands, and an element read answers the receiver's elements. A
# call with a block keeps the general rule, so its parameters still take
# the receiver's elements -- including from a receiver a method the
# compiler supplies builds, as ThreadGroup's list does. A call on what
# either answers, or on a block's parameter, reaches every class.
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

# a group's members through the list ThreadGroup keeps (builtins/thread_group.rb)
g = ThreadGroup.new
q = Queue.new
t = Thread.new { q.pop }
g.add(t)
p g.list.include?(t)
p ThreadGroup::Default.list.include?(t)
p ThreadGroup::Default.list.any? { |x| x.equal?(Thread.current) }
q << 1
t.join
p g.list.size
