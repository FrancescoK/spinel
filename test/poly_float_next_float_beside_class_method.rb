# A class method named next_float / prev_float belongs to a boxed Class;
# a boxed Float beside it still answers its own neighbours.
class Foo
  def self.next_float = "cls"
end
class Bar
  def self.prev_float = -2.5
end

# next_float: the class method answers a String, so the call is poly
[1.5, Foo].each { |x| p x.next_float }
p [1.5, 0][0].next_float
p [0.0, 0][0].next_float > 0.0

# prev_float: the class method answers a Float, so the call stays Float
[1.5, Bar].each { |x| p x.prev_float }
p [1.5, Bar].map { |x| x.prev_float + 1.0 }

begin
  [1, Foo][0].next_float
rescue NoMethodError => e
  p e.message
end
begin
  [Foo, 0][0].prev_float
rescue NoMethodError => e
  p e.class
end
