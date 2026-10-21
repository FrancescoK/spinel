# Reflection inference uses the user target selected by the call plan.
class ReflectionTarget
  def initialize = (@a = 1)
  def instance_variables = "own"
  def instance_variable_defined?(name) = "defined"
end
x = ReflectionTarget.new
p x.instance_variables
p x.instance_variable_defined?(:@a)
p x.send(:instance_variables)
