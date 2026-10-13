# In a class or module body self is the class, and a bare call of one of
# Object's methods that acts on it, or a Kernel method that runs a block,
# runs where it stands, as any other statement of the body does.
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
  puts "end of Shape"
end

module Util
  tap { |m| puts "tap #{m}" }
  module_eval { puts "module_eval #{self}" }
  module_exec { puts "module_exec" }
end

p Shape.new.area
