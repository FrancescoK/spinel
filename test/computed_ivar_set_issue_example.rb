# the example of #8219: a computed instance_variable_get and _set on an
# instance of a user class, the set of a name the class never writes with a
# literal, read back by its literal name
class Pt
  def initialize(x, y) = (@x = x; @y = y)
  def x = @x
end
pt = Pt.new(1, 2)
name = "@" + (ARGV[0] || "x")
p pt.instance_variable_get(name)
pt.instance_variable_set(name, 10)
p pt.x
pt.instance_variable_set("@" + (ARGV[1] || "z"), "zz")
p pt.instance_variable_get(:@z)
