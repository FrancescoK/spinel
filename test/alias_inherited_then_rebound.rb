# An alias of an inherited method takes the ancestor's body, even when the
# class then rebinds the old name with another alias. The alias was a
# forwarder that called the old name, so it reached the rebound method and,
# where that one called the alias back, recursed until the stack ran out.

class A
  def foo = :a
  def self.foo = :ca
end

class B < A
  def foo = [:b, super]
  def self.foo = [:cb, super]
end

class C < B
  def foo_quux = [:quux, foo_baz]
  alias_method :foo_baz, :foo
  alias_method :foo, :foo_quux
end
p C.new.foo, C.new.foo_baz, C.new.foo_quux

class D < B
  def bar = [:bar, old_foo]
  alias old_foo foo
  alias foo bar
end
p D.new.foo, D.new.old_foo

# class methods, aliased in `class << self`
class E < B
  class << self
    def foo_quux = [:quux, foo_baz]
    alias_method :foo_baz, :foo
    alias_method :foo, :foo_quux
  end
end
p E.foo, E.foo_baz

# a later def of the old name still leaves the alias on the inherited body
class F < B
  alias_method :orig, :foo
  def foo = [:f, orig]
end
p F.new.foo
