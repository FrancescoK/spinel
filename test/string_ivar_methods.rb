# A String keeps the instance variables a method the program adds to String
# sets on it, as CRuby's does: reads, writes, ||=, op-assign, defined?,
# attr accessors and the reflection all see one variable per String, and
# dup and clone copy them. A frozen String raises FrozenError on a write.
# The String has to be one name shares (a handle) for the variable to have
# an identity to live on; the share walk gives a String such a method is
# called on that identity.
class String
  attr_accessor :label
  def mark(v) = (@mark = v)
  def marked = @mark
  def tag = (@tag ||= :t)
  def count_up = (@n = (@n || 0) + 1)
  def known? = defined?(@tag)
end

s = String.new("s")
s.mark(1)
p s.marked
p s.known?
p s.tag
p s.known?
p s.count_up, s.count_up
s.label = "L"
p s.label
t = s
t << "!"
p s, s.marked, t.marked
p s.instance_variables
p s.instance_variable_get(:@mark)
s.instance_variable_set(:@a, [1])
p s.instance_variable_get(:@a), s.instance_variable_defined?(:@a), s.instance_variable_defined?(:@zz)

u = String.new("u")
p u.marked, u.known?, u.instance_variables
u.instance_variable_set(:@mark, 2)
p u.marked

d = s.dup
p d.marked, d.label, d.equal?(s)
d.mark(9)
p d.marked, s.marked
c = s.clone
p c.marked, c.frozen?

f = String.new("f").freeze
begin
  f.mark(1)
rescue FrozenError => e
  puts e.message
end
begin
  f.instance_variable_set(:@x, 1)
rescue FrozenError => e
  puts e.message
end
p f.marked

arr = [String.new("a"), String.new("b")]
arr.each_with_index { |x, i| x.mark(i) }
p arr.map(&:marked)
