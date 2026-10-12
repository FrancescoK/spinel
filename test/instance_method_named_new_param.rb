# An instance method named `new` is an ordinary method: its parameters are
# typed from the call sites, not from the default alone.
class Box
  def new(x = {}) = x
end
p Box.new.new({"c" => "d"})

class Bag
  def initialize(items = {})
    @items = items
  end

  def items = @items
end

class Holder
  def initialize(klass) = @klass = klass
  def new(items = {}) = @klass.new(items)
end

b = Holder.new(Bag).new({"k" => "a"})
p b.items
p Holder.new(Bag).new.items

class Plain
  def new = "made"
end
puts Plain.new.public_send(:new)

class Foo
  def initialize(a, b = {})
    @a = a
    @b = b
  end

  def show = [@a, @b]
end
p Foo.new(1).show
p Foo.new(2, {"k" => "v"}).show
