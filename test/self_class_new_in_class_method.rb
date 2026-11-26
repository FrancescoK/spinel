# In a class method self is a class, so `self.class.new` is Class.new: a
# new anonymous class at each call, with or without a superclass or a
# block, in a `def self.m`, a `def B.m`, a `class << self` or `class << B`
# def, a define_singleton_method body and an extended module's method. A
# block run with another self (instance_exec) makes that self's class's
# instance instead, and so does a class whose own `class` answers another
# class. A top-level def, or Object's or Kernel's, called from a class
# method makes a class the same way.
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

# A method whose self is a class only at run time: a top-level def (Object's),
# one of a reopened Object or Kernel. Called from a class method, its
# `self.class` is Class, a new class each call; called on an instance, its
# class's instance.
def mk_top = self.class.new
def mk_top_super = self.class.new(Base)
class Object
  def mk_obj = self.class.new
end
module Kernel
  def mk_ker = self.class.new
end
class D
  def self.top = mk_top
  def self.top_nil = mk_top.nil?
  def self.top_store = (@k = mk_top; @k.superclass)
  def self.top_two = [mk_top == mk_top, mk_top.class]
  def self.top_block = [1].map { mk_top.class }
  def self.top_super = mk_top_super
  def self.obj = mk_obj
  def self.ker = mk_ker
  def inst = mk_top
end
p D.top.class, D.top.superclass, D.top_nil, D.top_store, D.top_two, D.top_block
p D.top_super.superclass, D.top_super.new.who
p D.obj.class, D.obj.superclass, D.ker.class, D.ker.superclass
p D.new.inst.class, mk_top.class, D.new.mk_obj.class, D.new.mk_ker.class

# With a block: a class run makes a class whose body is the block, and an
# instance run hands the block to its class's initialize. A module's def
# whose block holds a def runs on an instance as its includer's method
# (its class run raises: self_class_new_refused_on_class_self).
class Y
  def initialize = (@b = block_given? ? yield : :none)
  attr_reader :b
end
def mk_top_blk = self.class.new { def hi = :top }
module Kernel
  def mk_ker_blk = self.class.new { def hi = :ker }
end
module Mk
  def mk_mod_blk = self.class.new { def hi = :mod }
end
class E
  include Mk
  extend Mk
  def self.top = mk_top_blk
end
p E.top.new.hi, Y.new.send(:mk_top_blk).b, Y.new.mk_ker_blk.b
p E.new.mk_mod_blk.class

# A block with a return, a yield or an instance variable runs only where the
# method runs: none of these runs at the start, and on an instance the block
# is the initialize's.
def mk_ret_u = self.class.new { return :early }
def mk_yld_u = self.class.new { yield + 1 }
def mk_ivar_u = self.class.new { @w = p(:side) }
class F
  def self.never = self.class.new { @v = p(:never) }
  def self.never_next = self.class.new { next 4 }
end
p Y.new.send(:mk_yld_u) { 6 }.b, Y.new.send(:mk_ret_u)

# A next or break whose target is a block or a loop inside the body stays
# inside it, so the statement runs again at each call: a class run makes
# the class, and an uncalled one runs nothing at the start. A builder
# nested in the block is that class's own body.
$jumps = []
def mk_loop_top = self.class.new { [1, 2].each { |i| next if i == 1; $jumps << i }; def hi = :top }
def mk_loop_unc = self.class.new { loop { $jumps << :unc; break }; def hi = :unc }
def mk_nest_top = self.class.new { self.class.new { def hi = :in } }
class G
  def self.each_next = self.class.new { [1, 2].each { |i| next if i == 1; $jumps << i }; def hi = :each }
  def self.loop_break = self.class.new { loop { break }; def hi = :loop }
  def self.while_next = self.class.new { i = 0; while i < 3; i += 1; next if i == 2; $jumps << i; end; def hi = :while }
  def self.top = mk_loop_top
  def self.nest = mk_nest_top
end
p $jumps
p G.each_next.new.hi, G.loop_break.new.hi, G.while_next.new.hi, G.top.new.hi, $jumps
p G.nest.class, Y.new.send(:mk_nest_top).b.b

# An object's singleton method runs on the object: `self.class` is its
# class, and the block goes to that class's initialize.
o = Y.new
def o.mk_osg = self.class.new { 8 }
class << o; def mk_osc = self.class.new { 9 }; end
p o.mk_osg.b, o.mk_osc.b, o.mk_osg.class, o&.mk_osg&.b, [o.mk_osg.b, o.mk_osc.b]
