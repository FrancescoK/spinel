# Klass.singleton_methods lists the class methods: defs, `class << self`
# methods, aliases and accessors; with the default `true` also those of the
# superclasses and extended modules.
class A
  def self.s = 1
  def self.t = 2
  def i = 3
  class << self
    def u = 4
    alias_method :v, :u
    attr_accessor :w
  end
end
class B < A
  def self.b = 5
end
module Ext
  def e = 6
end
class C
  extend Ext
  def self.c = 7
end
module M
  def self.m = 8
  def mf = 9
  module_function :mf
end
class D; end
p A.singleton_methods.sort
p A.singleton_methods(false).sort
p B.singleton_methods.sort
p B.singleton_methods(false)
p C.singleton_methods.sort
p C.singleton_methods(false)
p M.singleton_methods.sort
p D.singleton_methods
p A.singleton_methods.size

# an inherited class method specialized for the subclass is still the
# superclass's
class P
  def self.make = new
  def self.name2 = kind
  def self.kind = :p
end
class Q < P
  def self.kind = :q
end
p Q.make.class, Q.name2
p Q.singleton_methods(false).sort
p Q.singleton_methods.sort
p P.singleton_methods(false).sort
