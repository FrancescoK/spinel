# A def in `Klass.instance_eval { }` defines a method on Klass's singleton
# class, a class method, where `Klass.class_eval { def m }` defines an
# instance method. The def was not taken: the class answered the method
# a module it extends gives, or had none. Its own singleton method comes
# before the extended module's, and a subclass inherits it.
module Flags
  def flag? = false
  def label = "flags"
end
module Outer
  class Shape
    extend Flags
    @count = 3
    def flag? = self.class.flag?
  end
  class Square < Shape; end
  class Circle < Shape; end
end
Outer::Shape.instance_eval do
  def flag? = true
  def count = @count
  def twice(x) = x * 2
end
Outer::Square.instance_exec { def label = "square" }
Outer::Circle.class_eval { def label = "an instance's" }
class Holder
  instance_eval { def made = :made }
  self.instance_eval { def made_too = :made_too }
end

p Outer::Shape.flag?, Outer::Square.flag?, Outer::Shape.new.flag?
p Outer::Shape.count, Outer::Shape.twice(4)
p Outer::Shape.label, Outer::Square.label, Outer::Circle.label, Outer::Circle.new.label
p Holder.made, Holder.made_too
p Outer::Shape.respond_to?(:twice), Outer::Shape.new.respond_to?(:twice)
