# `String(s)` and `+s` answer s itself (`+s` unless s is frozen), so
# `equal?` against s is true in either order when s's slot holds the
# shared handle (an alias mutates it). The route's read face is a copy;
# the handles are compared. A frozen s's `+s` is a new String.
t = +"t"
q = t
q << "!"
p String(t).equal?(t), t.equal?(String(t)), String(t).equal?(q)
p (+t).equal?(t), t.equal?(+t)
t.freeze
p (+t).equal?(t), String(t).equal?(t)
u = +"u"
p String(u).equal?(u)
w = +"w"
w2 = +"w"
w << "x"
w2 << "x"
p String(w).equal?(w2)
class H
  def initialize = (@s = +"h")
  def go
    r = @s
    r << "!"
    String(@s).equal?(@s)
  end
end
p H.new.go
