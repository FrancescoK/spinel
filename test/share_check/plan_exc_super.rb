# The String plan's producers (#8328) name each route codegen hands a
# String on by. One no rule named before: super in an exception's message
# or to_s override, where the override publishes what it answers and the
# builtin's is the one it calls, hands on the message the exception keeps.
# The plan refused it, while the C handed over that handle; a change
# through either name shows through the other.
class E < StandardError
  def to_s = super
end
class G < StandardError
  def message = super
end
s = +"src"
e = E.new(s)
m = e.message
m << "!"
t = +"t"
g = G.new(t)
g.message << "?"
p s, e.to_s, t, g.message.equal?(t)
