# Repeated aliases contribute the same classes, including when a value is
# reached at different depths or as both a container and one of its elements.
class AliasLeft
  attr_reader :slot
  def initialize = @slot = 1
end
class AliasRight
  attr_reader :slot
  def initialize = @slot = 2
end
left = AliasLeft.new
right = AliasRight.new
b = [left, right][ARGV.size]
x = b
x = b
y = x
y = x.itself
z = y
z = y
z.instance_variable_set(:@slot, nil)
p left.slot, right.slot

# A second query has its own class set, even when it follows the same nodes.
z.instance_variable_set(:@slot, 7)
p left.slot, right.slot

# Value and element visits to the same local answer different questions.
items = [left, right]
v = [items, items[0]][1]
v.instance_variable_set(:@slot, 9)
p left.slot, right.slot

# The same local name in another scope must have a different visit key.
def write_right(obj)
  b = [obj, 0][0]
  x = b
  x = b
  x.instance_variable_set(:@slot, 11)
end
write_right(right)
p left.slot, right.slot

# A cycle still leaves the receiver unbounded at the walk's depth limit.
cycle = [left, 0][0]
cycle = cycle
cycle.instance_variable_set(:@slot, 13)
p left.slot, right.slot
