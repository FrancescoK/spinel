# Flag-only: without the flag (as on master) each call hands its parameter
# a copy, and the append through the parameter misses the caller's String.
# An argument that is no variable's read but hands on a shared String --
# `s << x`, `+s`, `String(s)`, `s.then { |v| v }` -- reaches a parameter
# the method appends to as that String's handle: in a plain call, with a
# count beside it, as a keyword, with a block, on an object, and through a
# dispatch over two classes. A route whose block makes a new String still
# hands over a String of its own.
def grow(u) = u << "!"
def grow2(u, n)
  n.times { u << "+" }
  u
end
def growk(u:) = u << "k"
def growb(u) = (yield; u << "b")
class G; def grow(u) = u << "g"; end
class H; def grow(u) = u << "h"; end
s = +"a"
t = s
grow(s << "x")
grow(+s)
grow(s.then { |v| v })
grow(String(s))
grow2(s << "y", 2)
growk(u: +s)
growb(+s) { 1 }
G.new.grow(+s)
[G.new, H.new][s.size % 2].grow(s.then { |v| v })
r = grow(s.then { |v| v + "f" })
p s, t, r
z = "lit"
begin; grow(+z); p z; rescue => e; p e.class; end
