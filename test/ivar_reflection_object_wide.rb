# A reflection method defined on Object is every object's, builtin values
# included: a call of a receiver of a known class reaches it, not the layout.
class Object
  def instance_variable_get(x) = :objwide
  def instance_variables = [:ow]
end
class Plain
  def initialize = (@p = 1)
end
class Own
  def instance_variable_get(x) = :own
end

p Plain.new.instance_variable_get(:@p)
p Own.new.instance_variable_get(:@p)
p 3.instance_variable_get(:@n), "s".instance_variable_get(:@n), nil.instance_variable_get(:@n)
p Plain.new.instance_variables, 3.instance_variables
