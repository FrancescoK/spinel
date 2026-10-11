# Two compact headers with the same leaf, `class X::Foo` and `class Y::Foo`,
# define two classes, as `module X; class Foo` and `module Y; class Foo` do.
# So do the classes and constants in their bodies, and a header's first
# segment is looked up from the scopes around it (`module A; class A::Foo`
# reopens the top-level A::Foo).
module X; end
module Y; end
class X::Foo
  LIM = 1
  class Bar; def w = "X Bar"; end
  def hi = "X::Foo#hi"
  def b = Bar.new.w
  def lim = LIM
end
class Y::Foo
  LIM = 2
  class Bar; def w = "Y Bar"; end
  def hi = "Y::Foo#hi"
  def only_y = "only Y"
  def b = Bar.new.w
  def lim = LIM
end
p X::Foo.new.hi, Y::Foo.new.hi
p X::Foo.new.respond_to?(:only_y), X::Foo.equal?(Y::Foo)
p X::Foo.name, Y::Foo.new.class
p X::Foo.new.b, Y::Foo.new.b, X::Foo::Bar.new.w, Y::Foo::Bar.new.w
p X::Foo.new.lim, Y::Foo.new.lim, X::Foo::LIM, Y::Foo::LIM

class Foo; def top = :top; end
class X::Baz; def x = "X::Baz"; end
class Baz; def x = "Baz"; end
p Foo.new.top, X::Foo.new.respond_to?(:top), Baz.new.x, X::Baz.new.x

module A; end
class A::Foo
  def one = 1
end
module A
  class A::Foo
    def two = 2
  end
end
p A::Foo.new.one, A::Foo.new.two

module B
  module C; end
  class C::Foo; def w = "B::C::Foo"; end
end
module C; class Foo; def w = "C::Foo"; end; end
p B::C::Foo.new.w, C::Foo.new.w

module Top; end
module M
  LIM = "M"
  class Top::Foo
    def l = LIM
  end
end
module N; LIM = "N"; end
p Top::Foo.new.l, N::LIM

# A head that is a constant holding a module stands for the module.
module P; end
module Q; end
AliasP = P
class AliasP::Foo
  def hi = "P::Foo#hi"
end
class Q::Foo
  def hi = "Q::Foo#hi"
end
p P::Foo.new.hi, Q::Foo.new.hi, AliasP::Foo.equal?(P::Foo), P::Foo.equal?(Q::Foo)
p P::Foo.name, AliasP::Foo.new.inspect.start_with?("#<P::Foo")

# Names follow the resolved path.
module D; module E; end; end
module F; module E; end; end
class D::E::Foo; end
class F::E::Foo; end
module Outer
  module In; end
  class In::Foo; end
end
module In; end
class In::Foo; end
p D::E::Foo.name, F::E::Foo.name, Outer::In::Foo.name, In::Foo.name
