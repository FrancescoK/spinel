# CRuby refuses to load this: "Foo is not a class (TypeError)".
# Foo names the builtin module Comparable, so `class Foo` cannot reopen it.
# spinel: reject-builtin-module: Foo is not a class (TypeError)
Foo = Comparable

class Foo
end

puts Foo.class
