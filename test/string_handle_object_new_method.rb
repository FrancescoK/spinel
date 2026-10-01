# A block handed to a method an object defines as `new`, which keeps it as
# `&b` and calls it later, appends to the caller's String: `new` names that
# method, not only the initialize a class's `new` reaches (#6179).
class Fac
  def new(&b) = (@b = b; self)
  def run(s) = @b.call(s)
  def go(s) = new { |t| t << "z" * 40 }.run(s)
end

s = +"s"
Fac.new.new { |t| t << "x" * 50 }.run(s)
p s.size
f = Fac.new
f.new { |t| t << "y" }.run(s)
p s[-1], s.size
u = +"u"
Fac.new.go(u)
p u.size

# a block that only reads keeps its String
r = +"r"
p Fac.new.new { |t| t.size }.run(r), r

