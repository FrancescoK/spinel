# A method added to Object, called on a receiver of unknown type: the arm
# for Object's own instances passes self boxed, and an omitted optional
# argument takes its default on every arm.
class Object
  def kind(x = 3) = is_a?(Integer) ? x : x + 1
  def tag = is_a?(String) ? :str : :other
end
v = [1, "a", Object.new][ARGV.size]
p v.kind
p v.kind(5)
p v.tag
p Object.new.kind
p Object.new.tag
w = [Object.new, 2][ARGV.size]
p w.kind
p w.tag
