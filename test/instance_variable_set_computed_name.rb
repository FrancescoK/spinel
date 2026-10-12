# instance_variable_set with a name built at run time, on an instance of a
# user class (#8219). A literal name resolved to the field at compile time;
# a computed one had no path and raised NoMethodError when it ran. The write
# now dispatches by the receiver's class and then by the name over the ivars
# the class declares, each stored as its literal write stores it; the
# analysis joined the value's type into every such field, so a field that
# may take a value of another type widens to a box. A name the class does
# not declare lives in a table keyed by the object, where a computed
# instance_variable_get finds it. On a typed receiver, on the implicit self,
# on a boxed receiver of several classes, on an exception, on a Struct, on
# main and on a bare Object; the call answers the value; a name without its
# `@` raises NameError, a frozen receiver (an immediate, a Data) FrozenError,
# as CRuby answers each.
class Pt
  def initialize(x, y) = (@x = x; @y = y)
  def x = @x
  def y = @y
  def write(n, v) = instance_variable_set(n, v)
end
pt = Pt.new(1, 2)
name = "@" + (ARGV[0] || "x")
p pt.instance_variable_set(name, 10)
p pt.x
p pt.instance_variable_set(name.to_sym, 11)
p pt.x, pt.y
p pt.write("@y", 5)
p pt.y
p pt.instance_variable_set("@" + "z", "extra")
p pt.instance_variable_get("@" + "z")
p pt.instance_variable_get("@" + "x")

# an Integer field that a computed write may give a String or nil
class Cell
  def initialize = @v = 1
  def v = @v
  def put(n, x) = instance_variable_set(n, x)
end
c = Cell.new
c.put("@" + "v", "str")
p c.v
c.put("@" + "v", nil)
p c.v
c.put("@" + "v", 3)
p c.v + 1

class Tag
  def initialize = @label = "t"
  def label = @label
end
class Count
  def initialize(n) = @n = n
  def n = @n
end
objs = [Pt.new(3, 4), Tag.new, Count.new(nil), Count.new(7), Object.new]
keys = ["@x", "@label", "@n", "@n", "@q"]
vals = [30, "u", 9, nil, :sym]
objs.each_with_index { |o, i| p o.instance_variable_set(keys[i], vals[i]) }
p objs[0].x, objs[1].label, objs[2].n, objs[3].n
p objs[4].instance_variable_get("@" + "q")
objs.each_with_index { |o, i| p o.instance_variable_get(keys[i]) }

class MyErr < StandardError
  def initialize(code) = (super("e"); @code = code)
  def code = @code
end
begin
  raise MyErr.new(1)
rescue StandardError => e
  e.instance_variable_set("@" + "code", 42)
  p e.instance_variable_get("@" + "code"), e.code
  e.instance_variable_set("@" + "extra", [1])
  p e.instance_variable_get("@" + "extra")
end

S = Struct.new(:a, :b) do
  def set(n, v) = instance_variable_set(n, v)
end
s = S.new(1, 2)
s.set("@" + "k", 7)
p s.instance_variable_get("@" + "k"), s.a

o = Object.new
o.instance_variable_set("@" + "w", 5)
p o.instance_variable_get(:@w)

@top = 1
self.instance_variable_set("@" + "top", 2)
p @top
self.instance_variable_set("@" + "other", 3)
p self.instance_variable_get("@" + "other")

begin
  pt.instance_variable_set("x", 1)
rescue NameError => e
  puts e.message
end
pt.freeze
begin
  pt.instance_variable_set("@" + "x", 2)
rescue FrozenError => e
  puts e.class
end
begin
  5.instance_variable_set("@" + "x", 2)
rescue FrozenError => e
  puts e.class
end
D = Data.define(:a)
begin
  D.new(1).instance_variable_set("@" + "a", 2)
rescue FrozenError => e
  puts e.message
end
