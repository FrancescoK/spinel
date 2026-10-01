# x ||= v and x &&= v name the local as every other write does: a local a
# proc captures lives in its cell, so `x &&= 7` beside one wrote an undeclared
# lv_x. And `x &&= v` in value position assigns only when x is not nil.

def t(xv, z)
  x = xv
  pr = proc { x = z }
  x &&= 7
  pr.call
  p x
end
t(1, 5)
t(nil, nil)
def e(xv)
  x = xv
  y = (x &&= 7)
  p [x, y]
end
e(1)
e(nil)
def f(xv)
  x = xv
  pr = proc { x }
  y = (x ||= 3)
  p [x, y, pr.call]
  s = :a
  s = nil if xv.nil?
  t = (s &&= :b)
  p [s, t]
end
f(nil)
f(2)
def g(xv)
  x = xv
  [1].each { x &&= x + 1 }
  p x
end
g(1)
g(nil)
