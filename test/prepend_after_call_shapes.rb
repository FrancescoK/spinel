# Calls a later prepend reaches early pick the class's own method until the
# prepend has run and the module's after it (#9982): a statement's call, a
# receiverless call in the class's own method, one on a subclass's object,
# one on a box that holds either, and one with an argument. CRuby prints the
# class's answers, then the module's.
class Dog
  def speak = "woof"
  def bark = speak + "?"
  def name(n) = "dog " + n
end
class Puppy < Dog
end
module Loud
  def speak = super.upcase + "!"
  def name(n) = super(n).upcase
end
def talk(d) = d.speak
def call_name(d, n) = d.name(n)
d = Dog.new
pup = Puppy.new
p d.speak, d.bark, talk(pup), call_name(d, "rex"), call_name(pup, "max")
class Dog
  prepend Loud
end
p d.speak, d.bark, talk(pup), call_name(d, "rex"), call_name(pup, "max")
