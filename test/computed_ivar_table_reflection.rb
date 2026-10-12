# The names a computed instance_variable_set puts in an object's table
# (#8219) are seen by the rest of the ivar reflection, as CRuby sees them:
# instance_variables lists them after the declared ones,
# instance_variable_defined? answers for them (with a literal name and a
# computed one, on a typed receiver and a boxed one), the default inspect
# shows them, dup and clone carry them, and remove_instance_variable takes
# one out (and raises NameError for a name never set).
class Pt
  def initialize(x) = @x = x
  def x = @x
end
class Bag
  def initialize = @a = 1
end
pt = Pt.new(1)
pt.instance_variable_set("@" + "z", "zz")
p pt.instance_variables
p pt.instance_variable_defined?(:@z), pt.instance_variable_defined?(:@w)
n = "@" + "z"
p pt.instance_variable_defined?(n), pt.instance_variable_defined?("@" + "x"), pt.instance_variable_defined?("@" + "w")
p pt.inspect.sub(/0x[0-9a-f]+/, "X")
d = pt.dup
p d.instance_variable_get("@" + "z"), d.instance_variables
c = pt.clone
p c.instance_variable_get(:@z)
o = [pt, 1][0]
p o.instance_variables, o.instance_variable_defined?(:@z)
[pt, Bag.new, Object.new, [1]].each { |v| p v.instance_variable_defined?(n), v.instance_variable_defined?("@" + "a") }
p pt.remove_instance_variable(:@z)
p pt.instance_variables, pt.instance_variable_defined?(n)
begin
  pt.remove_instance_variable(:@z)
rescue NameError => e
  puts e.message
end
begin
  pt.instance_variable_defined?("x" + "")
rescue NameError => e
  puts e.message
end
