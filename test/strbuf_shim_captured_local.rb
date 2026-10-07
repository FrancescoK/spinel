# A String local that a closure captures, with a second name for it, changed
# in place by clear, insert, setbyte, []= or slice!. Those run their String
# arm on a plain copy and swap its bytes into the shared buffer, so every
# name sees the change. The swap read the buffer as `lv_<name>`, which a
# captured local does not have (it lives in a cell, and inside the closure in
# the capture struct), and the arm wrote the cell a new String instead of
# the copy: the C did not compile.

# 1. inside a lambda, the second name taken there
s = +"abc"
f = lambda do
  t = s
  s.clear
  p [s, t]
end
f.call

# 2. each mutator, inside a proc
a = +"abc"
pr = proc do
  b = a
  a.insert(1, "-")
  p [a, b]
  a.setbyte(0, 90)
  p [a, b]
  a[1] = "+"
  p [a, b]
  a.slice!(0)
  p [a, b, b.equal?(a)]
end
pr.call

# 3. in the local's own scope, where a lambda keeps its cell
u = +"xyz"
size = lambda { u.size }
w = u
u.insert(0, "<")
u[-1] = ">"
p [u, w, size.call]

# 4. the mutator's value used, inside a lambda
v = +"hello"
g = lambda do
  y = v
  r = (v.insert(5, "!"))
  q = v.setbyte(0, 72)
  p [v, y, r, q]
end
g.call

# 5. in a method, through a proc
def run
  m = +"mno"
  h = proc do
    n = m
    m.clear
    m.insert(0, "k")
    p [m, n]
  end
  h.call
  p m
end
run
