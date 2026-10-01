# A String local written from a boxed local an `is_a?(String)` guard
# narrowed is a second name for the String in the box, as in CRuby: an
# append through the local reaches the box's String. It was a copy.

X = "x"
x = [1, +"q"][1]
if x.is_a?(String)
  t = x
  t << X
end
p x

y = [1, +"r"][1]
u = y.is_a?(String) ? y : "n"
u << X
p u, y

z = [1, +"s"][1]
v = (z if z.is_a?(String)) || +"m"
v << X << "!"
p v, z

def app(a) = (b = a if a.is_a?(String); b << X if b; a)
w = +"w"; p app(w), w
p app(3)

k = [2, :k][1]
m = k.is_a?(String) ? k : +"none"
m << X
p m, k
