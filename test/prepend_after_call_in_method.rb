# The call that runs ahead of the later prepend sits in a method body:
# `talk(d)` runs it before the module is there and after it (CRuby prints
# "woof", then "LOUD woof"). The call picks its method by whether the
# prepend has run when it runs (#9982).
module Loud
  def speak = "LOUD " + super
end
class Dog
  def speak = "woof"
end
def talk(d) = d.speak
d = Dog.new
puts talk(d)
class Dog
  prepend Loud
end
puts talk(d)
