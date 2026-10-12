# An argument that hands on a String through a conditional whose condition
# changes it (`f(s.downcase! ? s : s)`) is that String, also where the
# call's arguments run ahead of its binding beside a default that runs
# code: the parameter that appends appends to the caller's String. Built
# --share-strings, it appended to a copy. Covered: a ternary with a String
# or a nil arm, `if`, `case`, an arm of statements, a second argument, a
# keyword argument with an effect, and a method of an object.
def f(x = +"d") = (x << "!" if x; x)
s = +"AB"
f(s.downcase! ? s : s)
p s
f(s.upcase! ? s : nil)
p s
f(s.downcase! ? nil : s)
p s
f(if s.capitalize! then s else s end)
p s
f(case s.swapcase! when nil then s else s end)
p s
f(s.empty? ? nil : (s.downcase!; s))
p s

def g(x, y = +"d") = x << "?"
g(s.upcase! ? s : s)
p s
def k(x, k: 0) = x << "#{k}"
k(s.downcase! ? s : s, k: (s << "-"; 2))
p s

class C
  def m(x = +"d") = x << "."
end
C.new.m(s.upcase! ? s : s)
p s
t = +"xy"
f(s.downcase! ? s : t)
p s, t
