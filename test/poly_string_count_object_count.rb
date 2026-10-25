# A program that defines count on Object does not reach a String with it:
# String#count is the String's own method, and with no argument it raises
# ArgumentError. A Symbol has no count of its own, so it takes Object's.

class Object
  def count = "object count"
end

class Foo
  def count = "foo count"
end

s = +""
s << "abc"
[Foo.new, "hello", :sym, s, [1, 2]].each do |x|
  begin
    p x.count
  rescue ArgumentError => e
    p e.class
  end
end
