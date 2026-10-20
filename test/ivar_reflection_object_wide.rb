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

# ...and for a receiver that can be of any class: an instance of a program
# class without a method of its own, one with, a builtin value, nil
class Own2
  def instance_variable_get(x) = :own
end
class Object
  def instance_variable_set(k, v) = [:set, k, v]
  def instance_variable_defined?(k) = :defd
end
xs = [Plain.new, Own2.new, 3, nil, "s", Object.new]
xs.each { |x| p x.instance_variable_get(:@p) }
xs.each { |x| p x.instance_variable_set(:@p, 5) }
xs.each { |x| p x.instance_variable_defined?(:@p) }
xs.each { |x| p x.instance_variables }
p [Plain.new, "s"][ARGV.size].instance_variable_get(:@p)
o = Object.new
p o.instance_variable_get(:@n), o.instance_variables
