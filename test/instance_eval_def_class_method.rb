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

# the receiver is read by its whole path: a class of the same leaf in
# another module is another class, and a path written inside a module
# body is looked up from there
module Left
  class Part; end
end
module Right
  class Part; end
  Part.instance_eval { def side = :right }
end
Left::Part.instance_eval { def side = :left }
p Left::Part.side, Right::Part.side

# a compact header in a module body names the class its first segment
# resolves to: `class Box::Lid` inside Wrap defines the top-level Box::Lid
class Box; end
module Wrap
  class Box::Lid; end
end
Box::Lid.instance_eval { def fits = :lid }
p Box::Lid.fits, Box::Lid.name
