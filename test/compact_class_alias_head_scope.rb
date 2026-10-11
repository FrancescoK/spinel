# A compact header whose head is a constant holding a module (`A = ::P;
# class A::Foo`) names that module, looked up the way Ruby does: the head
# from the scopes around the header, the alias's value from the scopes
# around its write, a `::` anchor kept, and an alias of an alias followed.
module P1; class Foo; def hi = "top"; end; end
module Q1
  module P1; end
  A = ::P1
  class A::Foo; def hi2 = "reopened"; end
end
p P1::Foo.new.hi2, P1::Foo.name

module P2; end
module Q2
  module P2; end
  A = P2
  class A::Foo; end
end
p Q2::P2::Foo.name

module X3; end
module Y3; end
module S3; M = X3; end
M3 = Y3
class M3::Foo; end
module S3; class M::Foo; def w = "S3"; end; end
p Y3::Foo.name, X3::Foo.new.w, X3::Foo.name

module P4; end
B4 = P4
A4 = B4
class A4::Foo; def hi = "chain"; end
p P4::Foo.new.hi, P4::Foo.name

module X5; class Bar; end; end
K5 = X5::Bar
class K5::Foo; end
module AM5; end
AM = AM5
module AM::Mod; def self.w = "mod"; end
p X5::Bar::Foo.name, AM5::Mod.w, AM5::Mod.name

module P6; end
module Q6
  module P6; end
  A = ::P6
  class A::Foo; LIM = 1; def l = LIM; end
end
class Q6::P6::Foo; LIM = 2; def l = LIM; end
p P6::Foo.new.l, Q6::P6::Foo.new.l, P6::Foo.name, Q6::P6::Foo.name

# An alias a superclass holds, an alias of a Struct constant, an alias
# whose value goes through another alias, and reads of aliased headers.
module P7; class Foo; def a = 1; end; end
class Base7; A = P7; end
class Sub7 < Base7
  class A::Foo; def b = 2; end
end
p P7::Foo.new.a, P7::Foo.new.b

module X8; S = Struct.new(:a); end
class X8::S::Foo; def a = 1; end
A8 = X8::S
class A8::Foo; def b = 2; end
p X8::S::Foo.new.a, X8::S::Foo.new.b

module P9; class Foo; end; end
module R9; class Foo; end; end
module Q9a; A = P9; class A::Foo; def x = 1; end; def self.t = A::Foo.new.x; end
module Q9b; A = R9; class A::Foo; def x = 2; end; def self.t = A::Foo.new.x; end
p Q9a.t, Q9b.t, Q9a::A::Foo.new.x

module X10; end
module S10; M = X10; end
B10 = S10::M
class B10::Foo; def hi = "b"; end
p X10::Foo.new.hi, X10::Foo.name

# A constant holding a Struct is a namespace of its own, an alias written
# in Object's body is still the only one, and a value read the consts pass
# renamed keeps the name the program wrote.
module X11; class Foo; def a = "x"; end; end
S11 = Struct.new(:a)
class S11::Foo; def a = "s"; end
A11 = S11
p A11::Foo.new.a, X11::Foo.new.a

module P12; class Foo; def a = 1; end; end
module Z12; module A12; def self.z = 9; end; end
class Object; A12 = P12; end
module M12; class A12::Foo; def b = 2; end; end
p P12::Foo.new.b, P12::Foo.name, Z12::A12.z

module X13; S = Struct.new(:a); end
module Y13; S = Struct.new(:b); end
A13 = X13::S
class A13::Foo; def b = 2; end
p X13::S::Foo.new.b, X13::S::Foo.name
