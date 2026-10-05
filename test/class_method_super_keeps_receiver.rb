# A class method inherited by a subclass runs with self the subclass, and
# so does the method its super reaches -- also when the method calling
# super never names self itself.
module Base
  def who = name
end

module Wrap
  def who = "<" + super + ">"
end

class Parent
  extend Base
  extend Wrap
end

class Child < Parent; end

class Plain
  def self.label = name.downcase
end

class Fancy < Plain
  def self.label = "*" + super + "*"
end

class Fancier < Fancy; end

p Parent.who
p Child.who
p Fancy.label
p Fancier.label
