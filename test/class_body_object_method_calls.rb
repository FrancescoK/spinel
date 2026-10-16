# In a class or module body self is the class, and a bare call of one of
# Object's methods that acts on it, or a Kernel method that runs a block,
# runs where it stands, as any other statement of the body does; a bare
# Object or Module method used as a value answers about the class.
class Shape
  tap { |k| puts "tap #{k}" }
  yield_self { |k| puts "yield_self #{k}" }
  display
  puts
  public_send(:display)
  puts
  instance_eval { puts "instance_eval #{self}" }
  instance_exec(2) { |n| puts "instance_exec #{n} #{self}" }
  class_eval do
    def area = 0
    puts "class_eval #{self}"
  end
  class_exec { puts "class_exec" }
  loop do
    puts "loop"
    break
  end
  catch(:done) do
    puts "catch"
    throw :done
  end
  p itself, name, to_s, inspect, frozen?, superclass
  p is_a?(Class), kind_of?(Module), instance_of?(Class), nil?, equal?(Shape)
  p ancestors.first, include?(Kernel), included_modules.include?(Kernel)
  p object_id == Shape.object_id, object_id.is_a?(Integer)
  p instance_methods(false), method_defined?(:area), instance_method(:area).name
  label = "#{name}!"
  p label
  puts "end of Shape"
end

module Util
  tap { |m| puts "tap #{m}" }
  module_eval { puts "module_eval #{self}" }
  module_exec { puts "module_exec" }
  p name, is_a?(Class), instance_of?(Module)
end

p Shape.new.area
