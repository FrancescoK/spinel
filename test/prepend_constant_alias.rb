# A `prepend` of a constant that aliases a module (`Loud = Shout`) prepends
# that module, as an `include` of such a constant includes it: its methods
# come first, and their `super` reaches the class's own.
module Shout
  def greet = super.upcase + "!"
  def tag = "shout"
end
Loud = Shout
class Person
  prepend Loud
  def greet = "hello from #{self.class}"
  def tag = "person"
end
p Person.new.greet, Person.new.tag
p Person.ancestors.take(2), Person.include?(Loud)
module Wrap
  Inner = Shout
end
class Robot
  prepend Wrap::Inner
  def greet = "beep"
end
p Robot.new.greet
class Quiet
  include Loud
  def greet_base = "q"
end
p Quiet.ancestors.take(2), Quiet.include?(Shout), Quiet.new.tag
