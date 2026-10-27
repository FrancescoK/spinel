# The load record holds a prepend into a class's singleton class as that,
# at the statement that makes it (--dump-load-record,
# record_sclass_main.rb.load-record): in front of the singleton's own
# methods, whether written `class << K; prepend M; end`,
# `K.singleton_class.prepend(M)` or `class << self; prepend M; end` in K's
# body, where an include there is an extend. A call ahead of the statement
# reaches the class's own method, as in CRuby.
module Loud
  def speak = "LOUD " + super
end

module Plain
  def speak = "plain"
end

class Dog
  def self.speak = "woof"
end

class Cat
  def self.speak = "meow"
  class << self
    prepend Loud
  end
end

class Bird
  def self.speak = "tweet"
end

puts Dog.speak
class << Dog
  prepend Loud
end
puts Dog.speak
puts Cat.speak
Bird.singleton_class.prepend(Plain)
puts Bird.speak
