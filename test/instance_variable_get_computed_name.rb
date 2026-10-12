# instance_variable_get with a name built at run time, on an instance of a
# user class. A literal name resolved to the field at compile time; a
# computed one had no path and was refused. The read now dispatches by the
# receiver's class and then by the name over the ivars the class declares,
# each boxed as its literal read is: on a typed receiver, on the implicit
# self, on a boxed receiver of several classes, on an exception, and on a
# bare Object (its own table). An undeclared name reads nil, a Struct member
# is no ivar, an Integer ivar holding nil reads nil, and a name without its
# `@` raises NameError, as CRuby answers each.
class Pt
  def initialize(x, y) = (@x = x; @y = y)
  def x = @x
  def read(n) = instance_variable_get(n)
end
pt = Pt.new(1, 2)
name = "@" + (ARGV[0] || "x")
p pt.instance_variable_get(name)
p pt.instance_variable_get(name.to_sym)
p pt.instance_variable_get("@" + "y")
p pt.instance_variable_get("@" + "z")
p pt.read("@y"), pt.read(:@x), pt.read("@nope")

class Tag
  def initialize = @label = "t"
end
class Count
  def initialize(n) = @n = n
  def n = @n
end
[Pt.new(3, 4), Tag.new, Count.new(nil), Count.new(7), Object.new, 5].each_with_index do |o, i|
  key = ["@x", "@label", "@n", "@n", "@q", "@x"][i]
  p o.instance_variable_get(key)
end

o = Object.new
o.instance_variable_set(:@q, "set")
p o.instance_variable_get("@" + "q")

S = Struct.new(:a, :b)
s = S.new(1, 2)
p s.instance_variable_get("@" + "a")

class MyErr < StandardError
  def initialize(code) = (@code = code; super("e#{code}"))
end
begin
  raise MyErr.new(42)
rescue MyErr => e
  p e.instance_variable_get("@" + "code")
end

begin
  pt.instance_variable_get("x" + "")
rescue NameError => e
  puts e.message
end
