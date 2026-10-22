# Reflection records name the own, inherited and reopened user methods.
# spinel: gc-stress
class OwnReflection
  def initialize = (@n = 4)
  def instance_variable_get(name) = 41
  def instance_variables = [:own]
end
class ChildReflection < OwnReflection
  def instance_variable_get(name) = super + 1
end
class OwnReflection
  def instance_variables = [:reopened]
end
p OwnReflection.new.instance_variable_get(:@n)
p OwnReflection.new.instance_variables
p ChildReflection.new.instance_variable_get(:@n)
p ChildReflection.new.instance_variables
[OwnReflection.new, ChildReflection.new, 3].each do |obj|
  p obj.instance_variable_get(:@n)
  p obj.instance_variables
end
