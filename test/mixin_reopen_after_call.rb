# A module mixed in by a later reopening of a class leaves alone the calls
# ahead of it that it does not change: a method the class defines itself
# beats an include, a subclass's own method beats a prepend on its parent,
# another name is not touched, and a prepend in the first definition is
# there from the start.
module Kind
  def speak = "kind"
end
module Loud
  def speak = "LOUD " + super
end

class Cat
  def speak = "meow"
end
c = Cat.new
puts c.speak
class Cat
  include Kind
end
puts c.speak

class Dog
  def speak = "woof"
  def name = "rex"
end
class Pup < Dog
  def speak = "yip"
end
d = Dog.new
pup = Pup.new
puts d.name
puts pup.speak
class Dog
  prepend Loud
end
puts d.speak
puts pup.speak

class Owl
  prepend Loud
  def speak = "hoot"
end
puts Owl.new.speak
