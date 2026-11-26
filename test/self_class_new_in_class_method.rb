# In a class method self is a class, so `self.class.new` is Class.new: a
# new anonymous class at each call, with or without a superclass or a
# block, in a `def self.m`, a `def B.m`, a `class << self` or `class << B`
# def, a define_singleton_method body and an extended module's method. A
# block run with another self (instance_exec) makes that self's class's
# instance instead, and so does a class whose own `class` answers another
# class.
class Base
  def who = :base
end

class Other; end

class B
  def self.local
    k = self.class.new
    [k.class, k.superclass, k.name, k == B]
  end

  def self.tail = self.class.new

  def self.with_block
    self.class.new do
      def hi = :hi
    end
  end

  def self.with_super = self.class.new(Base)

  def self.super_block
    self.class.new(Base) { def who = [:sub, super] }
  end

  class << self
    def in_sclass = self.class.new
  end

  def self.eq = [self.class.new == self.class.new, self.class == Class]

  def self.class_of = self.class.new.class

  def self.in_block = [1, 2].map { self.class.new.superclass }

  def self.declined
    pr = proc { self.class.new }
    Other.new.instance_exec(&pr).class
  end
end

class Foo
  def initialize = (@v = 1)
  attr_reader :v
end

class Own
  def self.class = Foo
  def self.mk = self.class.new
end

class OwnS
  class << self
    def class = Foo
    def mk = self.class.new
  end
end

module Maker
  def made
    self.class.new
    :ok
  end
  def made_nil = self.class.new.nil?
  def made_super = self.class.new.superclass
end

class C
  extend Maker
  define_singleton_method(:dsm) { self.class.new.superclass }
end

def C.by_const = self.class.new.superclass

class << C
  def in_sclass_const = self.class.new.class
end

p B.local
k = B.tail
p k.class, k.name, k.superclass
w = B.with_block
p w.new.hi, B.with_block == w
s = B.with_super
p s.superclass, s.new.who, s.new.is_a?(Base)
p B.super_block.new.who
p B.in_sclass.superclass
p B.eq
p B.class_of
p B.in_block
p B.declined
p Own.mk.v, OwnS.mk.v
p C.made, C.made_nil, C.made_super
p C.dsm, C.by_const, C.in_sclass_const
