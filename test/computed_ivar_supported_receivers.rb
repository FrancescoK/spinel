# Runtime names keep the builtin maps and user overrides working.
name = :@value
array = []
hash = {}
plain = Object.new
p array.instance_variable_set(name, 7)
p array.instance_variable_get(name)
p hash.instance_variable_set(name, 7)
p hash.instance_variable_get(name)
p plain.instance_variable_set(:@value, 7)
p plain.instance_variable_get(:@value)
class ReflectionOverride
  def instance_variable_get(name) = 21
  def instance_variable_set(name, value) = value + 1
end
obj = ReflectionOverride.new
p obj.instance_variable_get(name)
p obj.instance_variable_set(name, 21)
class LiteralReflection
  def initialize = (@value = 4)
end
literal = LiteralReflection.new
p literal.instance_variable_get(:@value)
p literal.instance_variable_set("@value", 5)
p literal.instance_variable_get("@value")

# An unread lambda does not reach its reflective getter.
unused_getter = -> { name = :@value; LiteralReflection.new.instance_variable_get(name) }
puts "unused getter"
