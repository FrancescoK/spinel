# instance_variable_set with a computed name on a boxed receiver that may be
# an instance of a class defining its own instance_variable_set: the by-name
# store cannot call the program's method, so the shape stays refused (a
# typed receiver of that class binds to the method as any call does).
class Plain
  def initialize = @v = 1
  def v = @v
end
class Override
  def instance_variable_set(name, value) = value + 1
end
name = "@" + "v"
[Plain.new, Override.new].each { |o| p o.instance_variable_set(name, 5) }
