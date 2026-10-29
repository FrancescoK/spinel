# A call that runs before the method it names is defined raises, as in
# CRuby: a class body, a module body and the top level run their
# statements in order, so a receiverless, `self.` or constant-receiver call
# there finds only what the statements before it defined. A bare name
# raises NameError, any other call NoMethodError.

class U
  begin
    X = zz
  rescue NameError => e
    puts e.message
  end
  begin
    zz(1)
  rescue NoMethodError => e
    puts e.message
  end
  begin
    self.zz
  rescue NoMethodError => e
    puts e.message
  end
  begin
    U.zz
  rescue NoMethodError => e
    puts e.message
  end
  begin
    p zz if true
  rescue NameError => e
    puts e.message
  end
  def self.zz(a = 0) = 5 + a
  p zz
  p zz(1)
  p self.zz
end
p U.zz

module M
  begin
    zz
  rescue NameError => e
    puts e.message
  end
  begin
    zz(2)
  rescue NoMethodError => e
    puts e.message
  end
  def self.zz(a = 0) = 7 + a
  p zz
end

begin
  foo
rescue NameError => e
  puts e.message
end
begin
  foo(1)
rescue NoMethodError => e
  puts e.message
end
def foo(a = 0) = 9 + a
p foo
p foo(1)

# a redefinition between two calls: each call runs the version live there
class R
  def self.v = 1
  p v
  def self.v = 2
  p v
end
p R.v

# a block a method may keep runs later, after the def
def keep(&b) = ($kept = b)
keep { p later }
def later = :later
$kept.call

# an iterator's block runs at once, before the def
begin
  [1].each { early }
rescue NameError => e
  puts e.message
end
def early = :early
p early

# the superclass's class method answers before the class's own def
class Base
  def self.w = :base
end
class Kid < Base
  p w
  def self.w = :kid
  p w
end

# a constant receiver naming another module, before that module's def
class User
  begin
    p M.yy
  rescue NoMethodError => e
    puts e.message
  end
end
module M
  def self.yy = :yy
end
p M.yy

# main's singleton methods, a Class reopening's methods, a hook the
# language calls and a mixin a method adds, each before its call
def self.solo = :solo
p solo
class << self
  def helper(n) = n * 2
end
p helper(21)
class Class
  def greet = "#{name} greets"
end
class Greeted; end
p Greeted.greet
class Hooked
  def self.inherited(k) = puts("inherited #{k}")
end
class HookedKid < Hooked; end
module Ext
  def hooked? = true
end
module Store
  def self.hook! = ::Process.singleton_class.prepend(Ext)
end
Store.hook!
p Process.hooked?

# a builtin answers before the class's own def of its name, as in a class
# with no such def
class Kern
  puts "puts"
  p format("%d", 1)
  p Integer === rand(3)
  p sleep(0)
  p name
  def self.puts(*a) = print("[", *a, "]\n")
  def self.format(*) = :format
  def self.rand(*) = :rand
  def self.sleep(*) = :sleep
  def self.name = :name
  puts "puts"
  p format("%d", 1)
  p rand(3)
  p sleep(0)
  p name
end

# the raise happens wherever the call sits in the value
class Expr
  begin
    Y = zz + 1
  rescue NameError => e
    puts e.message
  end
  begin
    Z = [1, zz]
  rescue NameError => e
    puts e.message
  end
  begin
    W = zz ? 1 : 2
  rescue NameError => e
    puts e.message
  end
  begin
    p 1 if zz == 5
  rescue NameError => e
    puts e.message
  end
  def self.zz = 5
end

# a core class's reopening
class Integer
  begin
    xx
  rescue NameError => e
    p e.class, e.message
  end
  begin
    xx(1)
  rescue NameError => e
    p e.class, e.message
  end
  def self.xx(*) = 1
end

# Set is loaded at boot, before the require that names it
x = [Set, "ab"][ARGV.size]
p x[1]
require "set"
