# --emit-rbs declares a method the program names exactly as a prepend's hidden
# copy (`__prep 0 speak`), and only that one: the prepend's copy takes the next
# free index, `__prep 1 speak`, which is no method to declare.
module Loud
  def speak = "L " + super
end

class Animal
  def speak = "hi"
  define_method(:"__prep 0 speak") { "own" }
end

class Animal
  prepend Loud
end

p Animal.new.speak
p Animal.new.send(:"__prep 0 speak")
