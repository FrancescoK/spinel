# spinel: not-cruby -- CRuby makes a class on each class-self run below; Spinel raises NotImplementedError there
# A `self.class.new` in a method whose self is a class only when it runs (a
# top-level def, a module's def a class both includes and extends), with a
# block passed with `&`, a non-constant superclass or a builtin class as its
# superclass, a block that reads the method's locals or one with a
# statement that runs only once in a class body (a return, also one in a
# nested block, a yield, an instance variable), or, in a module's def, a
# block holding a def, or a block with a statement ahead of a
# declaration whose definition hook the program defines, can make no class where
# self is a class, and so can the same forms in a singleton's def, where
# every run is on a class:
# there it raises NotImplementedError (the compile warns of it), and a
# program that never runs it answers as CRuby does. The same def run on an
# instance or on main answers as CRuby does.
class Base
  def who = :base
end

def mk_blk(&b) = self.class.new(&b)
def mk_dyn(k) = self.class.new(k)
def mk_builtin = self.class.new(String)
def mk_local(x) = self.class.new { x + 1 }
def mk_ret = self.class.new { return :early }
def mk_yield = self.class.new { yield + 1 }
def mk_ivar = self.class.new { @w = 2 }
def mk_nret = self.class.new { [1].each { return :early } }
module Mx
  def mk_amp(&b) = self.class.new(&b)
end
class Y
  include Mx
  extend Mx
  def initialize(*a) = (@b = block_given? ? yield(*a) : :none)
  attr_reader :b
end

def attempt(label)
  r = yield
  puts "#{label}: #{r.class}"
rescue NotImplementedError, ArgumentError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

class B
  def self.blk = mk_blk { def hi = :hi }
  def self.dyn = mk_dyn(Base)
  def self.builtin = mk_builtin
  def self.local = mk_local(1)
  def self.ret = mk_ret
  def self.yld = mk_yield { 1 }
  def self.ivar = mk_ivar
  def self.nret = mk_nret
  def blk = mk_blk { }
  def dyn = mk_dyn(Base)
  def builtin = mk_builtin
end

attempt("class blk") { B.blk }
attempt("class dyn") { B.dyn }
attempt("class builtin") { B.builtin }
attempt("instance blk") { B.new.blk }
attempt("instance dyn") { B.new.dyn }
attempt("instance builtin") { B.new.builtin }
attempt("main blk") { mk_blk { } }
attempt("main dyn") { mk_dyn(Base) }
attempt("main builtin") { mk_builtin }
attempt("two") { [B.new.blk.class, B.blk] }
attempt("class local") { B.local }
attempt("class return") { B.ret }
attempt("class yield") { B.yld }
attempt("class ivar") { B.ivar }
attempt("class nested return") { B.nret }
p Y.new.send(:mk_local, 3).b, Y.new.send(:mk_yield) { 6 }.b, Y.new.send(:mk_nret)
attempt("module both, instance") { Y.new.mk_amp { 1 } }
attempt("module both, class") { Y.mk_amp { 1 } }

class C
  def self.amp(&b) = self.class.new(&b)
  def self.dyn(k) = self.class.new(k)
  def self.builtin = self.class.new(String)
  def self.local(x) = self.class.new { x + 1 }
  def self.ret = self.class.new { [1].each { return :early } }
  class << self
    def ivar = self.class.new { @w = 2 }
  end
  def self.never = self.class.new { return :never }
end
C.never if false
attempt("singleton amp") { C.amp { } }
attempt("singleton dyn") { C.dyn(Base) }
attempt("singleton builtin") { C.builtin }
attempt("singleton local") { C.local(1) }
attempt("singleton return") { C.ret }
attempt("singleton ivar") { C.ivar }

# a core module's def whose block holds a def: the def is the module's
# method where the block runs on an instance, so only the class run raises
module Kernel
  def mk_kdef = self.class.new { def kd = :kd; 5 }
end
class B
  def self.kdef = mk_kdef
end
attempt("core module def, class") { B.kdef }
p Y.new.mk_kdef.b, Y.new.kd, mk_kdef.class

# the same in a program's module a class includes and another extends; a
# value block there makes the class on a class run and is handed to
# initialize on an instance run
module Pdef
  def mk_pdef = self.class.new { def pd = :pd; 6 }
  def mk_pval = self.class.new { 8 }
end
class Y; include Pdef; end
class B; extend Pdef; end
attempt("module def, class") { B.mk_pdef }
p Y.new.mk_pdef.b, Y.new.pd, Y.new.mk_pval.b, B.mk_pval.class

# a statement ahead of a declaration whose definition hook (method_added)
# the program defines: the hook must see the statement run first, so the
# class run raises; a Class.new of that block evaluated once answers as CRuby
class B
  def self.hooked = self.class.new { def self.method_added(m) = puts("added #{m}"); puts :hbody; def hh = 1 }
end
attempt("definition hook, class") { B.hooked }
hk = Class.new { def self.method_added(m) = puts("added #{m}"); puts :hbody; def hh = 2 }
p hk.new.hh

# a use of the value that never runs: through a local, chained, as an argument
def takes(k) = k.class
if [1].size > 5
  x = C.amp { }
  p x.who
  p C.amp { }.who
  p C.ret.new, C.ivar.new.hi, C.ivar.instance_methods
  p takes(C.amp { })
end
p :dead_done
