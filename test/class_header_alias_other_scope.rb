# A class header looks its name up in its own owner only: an alias of the
# same name written in another module is no alias of it, and `class A` at
# the top level opens a new class there.
class Foo
  def foo = 1
end
module M
  A = Foo
end
class A
  def a = 2
end
p Foo.new.respond_to?(:a)
p A.new.respond_to?(:foo)
p M::A.equal?(Foo)
