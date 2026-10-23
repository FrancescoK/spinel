# The call ahead of the later prepend is a receiverless call in the class's
# own method, a call on self: CRuby prints "woofwoof", then
# "LOUD woofLOUD woof". Spinel's one chain, the last, would answer the
# module's method both times; refused.
module Loud
  def speak = "LOUD " + super
end
class Dog
  def speak = "woof"
  def twice = speak + speak
end
puts Dog.new.twice
class Dog
  prepend Loud
end
puts Dog.new.twice
