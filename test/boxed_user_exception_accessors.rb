# A user exception subclass reached through a boxed (poly) value answers
# Exception's accessors, as the builtin exception classes do.
P = Struct.new(:x)
class MyErr < StandardError; end
class SubErr < MyErr; end
class OwnToS < StandardError
  def to_s; "own to_s"; end
end
class OwnMsg < StandardError
  def message; "own message"; end
end
class EqErr < StandardError
  def ==(o); true; end
end

a = [MyErr.new("boom"), 1, P.new(1)]
puts a[0].message
puts a[0].to_s
p a[0]
p a[0].class
p a[0] == a[0]
p a[0] == MyErr.new("boom")
p a[0] == MyErr.new("other")
p a[2] == P.new(1)
p [MyErr.new("q")].include?(MyErr.new("q"))
p [EqErr.new("a"), 1][0] == EqErr.new("b")

b = [SubErr.new("sub"), "x"]
puts b[0].message
puts b[0].to_s
p b[0]

d = [OwnToS.new("x"), 1]
puts d[0].message
puts d[0].to_s
p d[0]

c = [OwnMsg.new("x"), 1]
puts c[0].message
s = [StandardError.new("std"), 1]
puts s[0].message

begin
  raise a[0]
rescue MyErr => e
  puts "rescued #{e.message}"
end
begin
  raise b[0]
rescue => e
  puts "rescued #{e.class} #{e.message}"
end

class Holder
  def initialize; @v = 1; end
  def set(x); @v = x; end
  def v; @v; end
end
h = Holder.new
h.set(SubErr.new("in ivar"))
puts h.v.message
hh = { a: MyErr.new("hv"), b: 2 }
puts hh[:a].message
puts hh[:a].to_s
puts [MyErr.new("x"), "s"].map { |v| v.to_s }.inspect
