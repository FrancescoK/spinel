# Literal names and constant superclass paths remain supported.
module StaticBuilders
  class Base
    define_method(:symbol_name) { 11 }
    define_method("string_name") { 12 }
    [:left, :right].each { |name| define_method("side_#{name}") { 13 } }
  end
end
NamedBuilder = Class.new(StaticBuilders::Base) {}
local = Class.new(StaticBuilders::Base)
p NamedBuilder.new.symbol_name
p NamedBuilder.new.string_name
p local.new.side_left
p local.new.side_right
p local.superclass == StaticBuilders::Base

# A literal name in a method body still defines its method, and a method
# nothing calls may use a computed name.
class MethodBodyBuilder
  def self.make
    define_method(:later) { next 1 }
    :made
  end

  def self.unused(name)
    define_method(name) { 2 }
  end
end
p MethodBodyBuilder.make
p MethodBodyBuilder.new.later

# Refusals belong to reachable operations, not every registered scope.
def unused_variable_parent(base)
  Class.new(base)
end
unused_parent = -> { base = StaticBuilders::Base; Class.new(base) {} }
class DeadComputedName
  define_method(:a.to_s) { 1 } if false
end
puts "pruned builders"
class MoreDeadBuilders
  define_method(:a.to_s) { 1 } unless true
  if false
    Class.new(StaticBuilders::Base.new)
  else
    define_method(:live) { 17 }
  end
end
p MoreDeadBuilders.new.live

# A lambda nothing reads may build a class from a variable superclass, whether
# a constant, an instance variable or a global holds it.
CONST_BUILDER = ->(base) { Class.new(base) {} }
$global_builder = ->(base) { Class.new(base) }
class IvarBuilderHolder
  def initialize = (@builder = ->(base) { Class.new(base) {} })
end
IvarBuilderHolder.new
puts "unread builders"
