# spinel: share
# spinel: gc-minor
# A local introduced inside the class block is not a captured outer local.
class BlockLocalBase
  def base_value = 10
end
klass = Class.new(BlockLocalBase) do
  value = 3
  define_method(:value) { value }
end
p klass.new.value
p klass.new.base_value

# An uncalled lambda does not make its captured class construction reachable.
unused_factory = -> { x = 1; Class.new { define_method(:value) { x } } }
puts "unused lambda"

# Nor does one held by a constant, an instance variable or a global that is never read.
HELD_FACTORY = -> { y = 2; Class.new { define_method(:value) { y } } }
$held_factory = -> { z = 3; Class.new { define_method(:value) { z } } }
class FactoryOwner
  def initialize(w) = (@factory = -> { Class.new { define_method(:value) { w } } })
end
FactoryOwner.new(4)
puts "unread holders"
