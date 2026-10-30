# --emit-rbs lists the methods a program names: a prepend renames the class's
# own `speak` to a hidden copy, which is no method to declare (the name has
# spaces, so a `def` of it is not RBS).
module Loud
  def speak = "L " + super
end

class Animal
  def speak = "hi"
end

class Animal
  prepend Loud
end

p Animal.new.speak
