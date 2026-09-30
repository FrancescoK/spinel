class String
  def blank2? = strip.empty? unless method_defined?(:blank2?)
  def upcase = "hijacked" unless method_defined?(:upcase)
  unless method_defined?(:to_s)
    def to_s = "nope"
  end
end
p " ".blank2?
p "x".upcase
p "y".to_s

class Range
  def overlap2?(o) = !(self.end < o.begin || o.end < self.begin) unless method_defined?(:overlap2?)
end
p (1..3).overlap2?(2..5)

module Helpers
  def greet = "hi" unless method_defined?(:greet)
  def greet2 = "first"
  def greet2 = "second" unless method_defined?(:greet2)
  def shout = "HEY" unless self.method_defined?(:shout)
end
class User
  include Helpers
end
p User.new.greet
p User.new.greet2
p User.new.shout

class Base
  def id = 1
end
class Child < Base
  def id = 2 unless method_defined?(:id)
end
p Child.new.id
unless String.method_defined?(:squish2)
  class String
    def squish2 = split.join(" ")
  end
end
p "a  b".squish2
