# `v&.upto(n) { }`, `v&.times { }` and the other loop iterators in statement
# or tail position skip a nil receiver, as CRuby's &. does; they walked it
# (upto and step counting up from the Integer sentinel, times raising).
def a(v)
  v&.upto(3) { print _1 }
  nil
end
p a(nil)
p a(1)
def b(v)
  v&.times { print _1 }
  0
end
p b(nil)
p b(2)
def c(v) = v&.upto(3) { print _1 }
p c(nil)
p c(1)
def d(v) = v&.times { print _1 }
p d(nil)
p d(2)
def e(v) = v&.step(10, 3) { print _1 }
p e(nil)
p e(1)
def f(v) = v&.downto(1) { print _1 }
p f(nil)
p f(2)
def g(a) = a&.each { print _1 }
p g(nil)
p g([1, 2])
def h(x) = x&.each_pair { |k, v| print k, v }
p h(nil)
p h({k: 1})
x = [nil, 2][0]
x&.times { print _1 }
puts
3.times { print _1 }
puts
