# An instance-side alias names an instance method only, and a singleton
# alias (`class << self; alias a b`) a class method only: an instance
# `alias name cop_name` made a class method's Module#name call the class
# method cop_name, which called back into it for good.
class A
  def self.b = "A.b"
  class << self
    alias a b
    alias_method :c, :b
  end
  def b = "A#b"
  alias a2 b
  def self.call_a = a
end
class Sub < A; end
p A.a, A.c, A.call_a, Sub.a, Sub.c
p A.new.a2, Sub.new.a2
p A.respond_to?(:a)
class Base
  def self.badge = "badge:#{name}"
  def self.cop_name = badge
  def cop_name = self.class.cop_name
  alias name cop_name
end
class Cop < Base; end
p Cop.cop_name, Cop.new.name, Base.name

# a class method the class defines itself answers ahead of the instance
# alias of a module it extends, whichever comes first
module Greeting
  def hello = "Greeting#hello"
  alias greet hello
end
class Own
  extend Greeting
  def self.greet = "Own.greet"
end
class OwnFirst
  def self.greet = "OwnFirst.greet"
  extend Greeting
end
p Own.greet, Own.hello, OwnFirst.greet
