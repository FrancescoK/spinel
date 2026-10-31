# The class-body macro form declines: a block that answers a frozen String a
# method made (the class's name), which is not the literal of its bytes.
class Base
  def self.label(n)
    s = self.name
    define_method(n) { s }
  end
end
class Foo < Base
  label :who
end
x = Foo.new.who
p x, x.frozen?, x.equal?(Foo.name), x.equal?("Foo")
