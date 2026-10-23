# The call that runs ahead of the later prepend sits in a method body:
# `talk(d)` runs it before the module is there (CRuby prints "woof", then
# "LOUD woof"). A method body may run at any time, so its call is refused
# too.
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
