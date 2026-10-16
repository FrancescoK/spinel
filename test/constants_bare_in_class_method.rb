# A bare `constants` in a class method lists the constants of the class
# the method was called on, a subclass's own first. In a class body it
# lists those assigned so far.

module Verbs
  GET = "GET"
  POST = "POST"
  def self.list = constants
  def self.own = constants(false)
  def self.each
    constants.each { |name| yield name.downcase, const_get(name) }
  end
end

p Verbs.list
p Verbs.own
Verbs.each { |n, v| puts "#{n} #{v}" }

class Base
  A = 1
  SO_FAR = constants
  def self.list = constants
  def self.own = self.constants(false)
end

class Sub < Base
  B = 2
  OWN_SO_FAR = constants(false)
end

p Base.list
p Sub.list
p Sub.own
p Base::SO_FAR
p Sub::OWN_SO_FAR
