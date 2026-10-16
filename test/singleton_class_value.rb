# A class's singleton class is a value of its own: Foo.singleton_class, self
# in a `class << Foo` body and `class << Foo; self; end` are #<Class:Foo>,
# whose name is nil, which equals only itself, and which cannot be
# instantiated. instance_methods(false) and method_defined? ask it about the
# class methods.
class Foo
  def self.make = 1
  class << self
    attr_accessor :conf
    def helper = 2
  end
end
class Bar < Foo
  def self.own = 3
end

sc = Foo.singleton_class
p sc, sc.name, sc.to_s, sc.inspect, "#{sc}", sc.class
p sc.singleton_class?, Foo.singleton_class?
p sc == Foo.singleton_class, sc == Foo, sc.equal?(Foo.singleton_class), Bar.singleton_class == sc
p [sc, Bar.singleton_class], { sc => 1 }[Foo.singleton_class]
p String.singleton_class, Comparable.singleton_class
k = Bar
p k.singleton_class, [sc, Foo].map(&:name)

class Shape
  class << self
    puts "defining on #{self}"
    p self, name, to_s
    $shape_sc = self
    def unit = 7
  end
end
class << Shape
  p self, inspect
end
p $shape_sc, $shape_sc == Shape.singleton_class, Shape.unit

class Holder
  SC = class << self
    def made = 1
    self
  end
  def self.meta = class << self; self; end
end
p Holder::SC, Holder.meta, (class << Holder; self; end) == Holder::SC

p Foo.singleton_class.instance_methods(false).sort, Bar.singleton_class.instance_methods(false)
p Foo.singleton_class.method_defined?(:make), Bar.singleton_class.method_defined?(:make),
  Foo.singleton_class.method_defined?(:new), Foo.singleton_class.public_method_defined?(:nope)
class Foo
  class << self
    p instance_methods(false).sort, method_defined?(:helper)
  end
end

begin
  sc.new
rescue TypeError => e
  p e.message
end
