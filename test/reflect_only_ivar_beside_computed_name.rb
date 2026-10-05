# An ivar only instance_variable_set writes (with a literal name) keeps its
# presence apart from its value; another instance_variable_set naming its
# ivar by a value -- here one that never runs -- is no literal to compare.
class Box
  def initialize(v) = @v = v
  def mark(flag) = instance_variable_set(:@marked, flag)
  def set(name, value) = instance_variable_set(name, value)
end
a = Box.new(1)
a.mark(nil)
b = Box.new(2)
b.mark(true)
p a.instance_variables, b.instance_variables
p b.instance_variable_get(:@marked), a.instance_variable_get(:@marked)
