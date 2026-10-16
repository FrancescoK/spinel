# `class Object::Foo` is the top-level Foo, the same as `class ::Foo`.
# It is not a class under an unknown parent.

class Object::Foo
  def a = "a"
end

class Foo
  def b = "b"
end

module Shop
  class Foo
    def c = "shop c"
  end

  class Object::Receipt
    def total = "top receipt"
  end
end

puts Foo.new.a + Foo.new.b
puts Shop::Foo.new.c
puts Foo.name
puts Receipt.new.total
puts Receipt.name
