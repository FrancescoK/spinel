# A class header whose name holds an alias of an alias reopens the class
# at the end of the chain.
class Foo; def foo = 1; end
B = Foo
A = B
class A; def a = 2; end
p Foo.new.respond_to?(:a)
p A.equal?(Foo)
