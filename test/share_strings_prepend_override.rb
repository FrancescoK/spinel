# A program-defined prepend keeps its own return value.
class String
  def prepend(a, b)
    +"fresh"
  end
end
s = +"old"
a = s
a << "!"
r = (s << "x").prepend("p", "q")
u = r
u << "?"
p s, a, r, u, r.equal?(s)
