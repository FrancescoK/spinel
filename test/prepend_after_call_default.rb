# A call that leaves out a defaulted argument and runs before a later
# prepend reaches the class's own method with that method's default, and
# after the prepend the module's with the module's: on an instance, a class
# method, one inherited from a superclass, and through two prepends.
module Loud
  def speak(x = 1) = "LOUD #{x} " + super
end
class Dog
  def speak(x = 2) = "woof #{x}"
end
def talk(d) = [d.speak, d.speak(5)]
d = Dog.new
p talk(d)
class Dog
  prepend Loud
end
p talk(d)

class Puppy
  def self.speak(x = 2) = x.to_s
end
p Puppy.speak
class Puppy
  class << self
    prepend Loud
  end
end
p Puppy.speak

class Animal
  def self.speak(x = 3) = x.to_s
end
class Kitten < Animal
end
p Kitten.speak
class << Kitten
  prepend Loud
end
p Kitten.speak

module Echo
  def speak(x = 4) = "echo #{x} " + super
end
class Bird
  def speak(x = 5) = "tweet #{x}"
end
def chirp(b) = b.speak
b = Bird.new
p chirp(b)
class Bird
  prepend Loud
end
p chirp(b)
class Bird
  prepend Echo
end
p chirp(b)
