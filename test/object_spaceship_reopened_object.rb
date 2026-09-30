# A program that reopens Object with its own `<=>` keeps it for the classes that
# have none of their own, including an operand that is an instance of one of the
# program's classes.
class Object
  def <=>(o) = 9
end

class Plain; end

r = /a/
pr = proc { }
q = Queue.new
e = RuntimeError.new("x")
pl = Plain.new
p [r <=> pl, pr <=> pl, q <=> pl, e <=> pl]
