# A prepend into a class's singleton class in a later reopening takes
# effect when the prepend runs, not when the reopening ends: a call in the
# reopening after `singleton_class.prepend M` or `class << self; prepend M;
# end` reaches M's method, and one between two such prepends reaches the
# first only. Each prepend's copies are guarded by a flag of their own,
# set right after it; the one flag was set after the whole reopening. An
# empty method of the module is guarded too: ahead of the prepend a call
# reaches the method the class had, not the empty copy.
module A
  def speak = "A " + super
end

module B
  def speak = "B " + super
end

module Quiet
  def speak; end
end

class Animal
  def self.speak = "..."
end

class Puppy < Animal
end

class Kit
  def self.speak = "mew"
end

class Pup < Animal
end

puts Puppy.speak
puts Kit.speak
p Pup.speak

class Puppy
  singleton_class.prepend A
  puts Puppy.speak
  class << self
    prepend B
  end
  puts Puppy.speak
end

class Kit
  singleton_class.prepend A
  puts Kit.speak
end

class Pup
  class << self
    prepend Quiet
  end
end

puts Puppy.speak
puts Kit.speak
p Pup.speak
puts Animal.speak
