# recv.const_get(:N) with a receiver known only at run time (a local, a
# parameter, a block parameter) searches the module the receiver holds, as
# a constant receiver does: a class nested in it wins over the top-level
# class of the same leaf.

module Admin
  class Foo
    def who = "Admin::Foo"
  end
end

module Shop
  class Item
    def who = "Shop::Item"
  end
end

class Base
  class Inner
    def who = "Base::Inner"
  end
end

class Sub < Base
  def inner_who = self.class.const_get(:Inner).new.who
end

class Leaf < Sub
end

class Inner
  def who = "Inner"
end

class Foo
  def who = "Foo"
end

m = Object.const_get("Admin")
puts m.const_get("Foo").new.who
puts m.const_get(:Foo).new.who

def look(mod, name) = mod.const_get(name)
puts look(Admin, "Foo").new.who
puts look(Object, "Foo").new.who
puts look(Shop, "Foo").new.who

[Admin, Shop, Object].each do |mod|
  puts mod.const_get("Foo").new.who
end

# a superclass's nested class, through a subclass held in a variable
def inner(klass) = klass.const_get(:Inner)
puts inner(Sub).new.who
puts inner(Leaf).new.who
puts inner(Admin).new.who
puts Leaf.new.inner_who

# const_get(name, true) searches the ancestors too
puts m.const_get(:Foo, true).new.who

# a class held boxed, out of an Array of modules and other values
[Admin, Shop, 1].each do |v|
  next unless v.is_a?(Module)
  puts v.const_get(:Foo).new.who
end

name = ARGV.empty? ? "Foo" : ARGV[0]
puts m.const_get(name).new.who
