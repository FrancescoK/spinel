# X::Foo takes the internal name X__Foo, which the program's own class
# X__Foo already has, and a top-level Foo exists too, so either name would
# merge two classes. It is refused rather than compiled to the wrong class.
module X; end
class X::Foo; def w = "X::Foo"; end
class X__Foo; def w = "X__Foo"; end
class Foo; def w = "Foo"; end
p X::Foo.new.w, X__Foo.new.w, Foo.new.w
