# A call that reaches a later prepend's copy only through a boxed receiver
# (an Array of classes or of objects) or a constant that aliases the class
# runs the method behind the copy before the prepend and the module's
# after, with whatever argument count it passes.
module Loud
  def speak(n = 1) = "LOUD #{n} " + super
end
class Animal
  def self.speak(n = 0) = "animal #{n}"
end
class Kitten < Animal
end
K = Kitten
def all(ks) = ks.map { |k| k.speak(7) }
ks = [Animal, Kitten]
p all(ks)
p K.speak
class << Kitten
  prepend Loud
end
p all(ks)
p K.speak

module Quiet
  def speak(n = 1) = "quiet #{n} " + super()
end
class Dog
  def speak = "woof"
end
class Pug < Dog
end
class Cat
  def speak = "meow"
end
P = Pug
def each_speak(xs) = xs.map { |a| a.speak }
xs = [Pug.new, Cat.new]
p each_speak(xs)
p P.new.speak
class Dog
  prepend Quiet
end
p each_speak(xs)
p P.new.speak
