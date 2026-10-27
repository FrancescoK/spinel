# A prepend into a class's singleton class that a later top-level statement
# makes takes effect when that statement has run, not from the start of the
# program: a call ahead of it reaches the class's own singleton method, as
# in CRuby. Written as `class << K; prepend M; end`, as
# `K.singleton_class.prepend(M)` and as `class K; singleton_class.prepend M;
# end`, with the prepended method calling super, with two modules, through
# a subclass and through a method defined ahead of the statement.
module Loud
  def speak = "LOUD " + super
  def shout = "LOUD shout"
end

module Soft
  def speak = "soft " + super
end

module Plain
  def speak = "plain"
end

class Dog
  def self.speak = "woof"
  def self.shout = "own shout"
  def self.talk = speak
end

class Puppy < Dog; end

class Cat
  def self.speak = "meow"
end

class Bird
  def self.speak = "tweet"
end

class Fish
  def self.speak = "blub"
end

def ask(k) = k.speak

puts Dog.speak
puts Dog.shout
puts Dog.talk
puts Puppy.speak
puts ask(Dog)
puts Cat.speak
puts Bird.speak
puts Fish.speak

class << Dog
  prepend Loud, Soft
end

puts Dog.speak
puts Dog.shout
puts Dog.talk
puts Puppy.speak
puts ask(Dog)
puts Cat.speak

Cat.singleton_class.prepend(Plain)
puts Cat.speak

class Bird
  singleton_class.prepend Plain
end
puts Bird.speak

# an include into the singleton class goes behind the class's own method
class << Fish
  include Plain
end
puts Fish.speak
puts Bird.speak
