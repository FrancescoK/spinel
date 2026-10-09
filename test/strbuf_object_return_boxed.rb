# spinel: share
# spinel: gc-minor
# A marked reader whose method returns a box keeps that representation.
# The module call supplies String values through polymorphic dispatch.
module BoxedElementReturn
  def get(f) = f ? @value : @value + "m"
end
class BoxedElementA
  include BoxedElementReturn
  def initialize(value) = @value = value
end
class BoxedElementB
  def get(f) = "b".dup
end
class BoxedElementHolder
  def initialize = @value = nil
  def put(value) = @value = value
  def value = @value
end
objects = [BoxedElementA.new("s".dup), BoxedElementB.new]
holder = BoxedElementHolder.new
p holder.value
holder.put(objects[0].get(false))
p holder.value << "!"
