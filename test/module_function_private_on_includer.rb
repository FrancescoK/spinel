# A module_function method is private on the module's instance side: an
# includer's instance calls it from its own methods, and a call with a
# receiver raises NoMethodError for a private method.
module M
  module_function
  def g = :g
end

class K
  include M
  def h = g
end

p M.g
p K.new.h
begin
  K.new.g
rescue NoMethodError => e
  puts e.message
end
p M.private_instance_methods(false), K.private_method_defined?(:g)
