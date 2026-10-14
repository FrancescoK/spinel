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
# through a chain of aliases, and an alias of a builtin module
Louder = Loud
class Crowd
  prepend Louder
  def greet = "crowd"
end
module Mixer
  prepend Louder
  def greet = "mixer"
end
class Party
  include Mixer
end
p Crowd.new.greet, Crowd.ancestors.take(2), Party.new.greet, Party.ancestors.take(3)
Enum = Enumerable
class Bag
  include Enum
  def each
    yield 1
    yield 2
  end
end
p Bag.ancestors.take(2), Bag.include?(Enumerable), Bag.new.map { |x| x * 2 }
