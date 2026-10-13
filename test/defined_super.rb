# defined?(super) answers "super" where the method's super reaches a method:
# one of the program's, an attr reader, a builtin's (BasicObject#initialize,
# Exception#message, Class#new, Module#included), and nil where none does.

class A
  def foo = 1
  def to_s = "A"
  def self.cm = 1
end
class B < A
  def foo = defined?(super)
  def bar = defined?(super)
  def to_s = defined?(super).inspect
  def inspect = defined?(super).inspect
  def self.cm = defined?(super)
  def self.other = defined?(super)
  def initialize = (@x = defined?(super))
  attr_reader :x
end
module M
  def mm = defined?(super)
end
class C
  include M
end
class D < C
  def mm = [defined?(super), super].inspect
end
module N; def mm = 7; end
class E; include N; include M; end
b = B.new
p b.foo, b.bar, b.to_s, b.inspect, B.cm, B.other, b.x
p C.new.mm, D.new.mm, E.new.mm

class Base
  attr_reader :name
  def self.build = :built
  def self.inherited(sub)
    super
    (@log ||= []) << defined?(super)
  end
  def self.log = @log
end
class Kid < Base
  def name = defined?(super)
  def self.build = defined?(super)
  def self.fresh = defined?(super)
  def self.new(*) = (@made = defined?(super); super)
  def self.made = @made
  def respond_to_missing?(n, p = false) = defined?(super) == "super"
end
class Oops < StandardError
  def message = "#{defined?(super)}: #{super}"
  def nope = defined?(super)
end
module Hooks
  def self.included(base) = ($inc = defined?(super))
end
class Host; include Hooks; end
kid = Kid.new
p kid.name, Kid.build, Kid.fresh, Kid.made, Base.log, kid.send(:respond_to_missing?, :zap)
p Oops.new("boom").message, Oops.new.nope, $inc

# a reopened builtin's own method is not above it
class String
  def shout = defined?(super)
  def upcase = defined?(super)
  def to_s = defined?(super) ? self : ""
end
p "a".shout, "a".upcase, "a".to_s

# an ancestor that undefs the name: the super reaches nothing
class UndefBase
  def probe = 1
end
class UndefMiddle < UndefBase
  undef :probe
end
class UndefLeaf < UndefMiddle
  def probe = defined?(super)
end
p UndefLeaf.new.probe
