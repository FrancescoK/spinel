# A prepend into the singleton class of a class with no class method of the
# name of its own, only one it inherits, takes effect when its statement
# runs too: a call ahead of a later reopening's `class << K; prepend M; end`
# or `singleton_class.prepend M` reaches the inherited method, as in CRuby,
# and one after it the prepended method, whose super reaches the inherited
# one. Inherited from a grandparent's def and from a parent's extend.
module Loud
  def speak = "LOUD " + super
end

module Sound
  def speak = "sound"
end

class Animal
  def self.speak = "..."
end

class Dog < Animal
end

class Puppy < Dog
end

class Bird
  extend Sound
end

class Chick < Bird
end

puts Puppy.speak
puts Chick.speak

class Puppy
  class << self
    prepend Loud
  end
end

class Chick
  singleton_class.prepend Loud
end

puts Puppy.speak
puts Dog.speak
puts Chick.speak
puts Bird.speak
