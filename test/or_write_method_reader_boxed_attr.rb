# `o.x ||= v` where a method written out reads x and an attr_accessor
# writes it, over a field that holds more than one class
class MethodAttr
  attr_accessor :name, :count

  def initialize(name, count)
    @name = name
    @count = count
  end
end

class AnyMethod < MethodAttr
  def name
    return @name if String === @name
    @name&.to_s
  end

  def count = @count
end

a = AnyMethod.new(nil, nil)
a.name ||= "unknown"
p a.name
b = AnyMethod.new(:sym, 1)
b.name ||= "unknown"
p b.name

# as a value, and `&&=`
c = AnyMethod.new(nil, "two")
got = (c.name ||= "fresh")
p got
p(c.name &&= "renamed")
p c.name
d = AnyMethod.new(nil, nil)
p(d.name &&= "never")

# an Integer into the field that holds a String or an Integer
a.count ||= 3
p a.count
p(c.count ||= 4)
p c.count
