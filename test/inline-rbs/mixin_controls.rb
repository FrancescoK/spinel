# spinel: not-cruby -- each false annotation here is applied and refused
# Methods that are reached without a mixin copy keep their annotations, so a
# false one is refused at the call: a superclass's instance method, a
# module's `def self.`, a module_function (on its own, included, or spelled
# `extend self`), an inherited class method, an alias_method copy, and a
# class's own method beside an `include`.
class Base
  #: (String) -> String
  def sup(n) = n * 2
  #: (String) -> String
  def self.cls(n) = n * 2
  #: (String) -> String
  def orig(n) = n * 2
  alias_method :copy, :orig
end
class Derived < Base
end
module Util
  #: (String) -> String
  def self.own(n) = n * 2
end
module Rt
  module_function
  #: (String) -> String
  def peek(n) = n * 2
end
module Shared
  module_function
  #: (String) -> String
  def wide(n) = n * 2
end
class User
  include Shared
  include Comparable
  def go = wide(4)
  #: (String) -> String
  def mine(n) = n * 2
end
module Selfish
  extend self
  #: (String) -> String
  def solo(n) = n * 2
end

p Derived.new.sup(1)
p Derived.cls(2)
p Base.new.copy(3)
p Util.own(4)
p Rt.peek(5)
p User.new.go
p User.new.mine(6)
p Selfish.solo(7)
