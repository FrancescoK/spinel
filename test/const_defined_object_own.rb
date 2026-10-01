X = 1
class Foo; Y = 2; end
module M; class Bar; end; end
p Object.const_defined?(:X, false)
p Object.const_defined?("Foo", false)
p Object.const_defined?(:M, false)
p Object.const_defined?(:String, false)
p Object.const_defined?(:RUBY_VERSION, false)
p Object.const_defined?(:Y, false)
p Object.const_defined?(:Bar, false)
p Foo.const_defined?(:Y, false)
p Foo.const_defined?(:X, false)
p Object.const_get(:X, false)
p Object.const_get(:Foo, false)
p((Foo.const_get(:X, false) rescue $!.class))
