# concat, replace, update and merge! put the elements of their arguments
# into the receiver: a later read of the receiver can answer one of them,
# and a call on it dispatches to that class's method
class A; def foo = "A"; end
class B; def foo = "B"; end
class C; def foo = "C"; end
class D; def foo = "D"; end

a = []
a.concat([B.new])
[A.new, a[0]].each { |v| puts v.foo }

r = [A.new]
r.replace([C.new])
[A.new, r[0]].each { |v| puts v.foo }

class Shape; def area = 0; end
class Square < Shape; def area = 4; end
class Circle < Shape; def area = 3; end
shapes = []
shapes.concat([Square.new])
[Circle.new, shapes[0]].each { |s| p s.area }

h = {}
h.update(k: B.new)
[A.new, h[:k]].each { |v| puts v.foo }

m = {}
m.merge!({ k: C.new })
[A.new, m[:k]].each { |v| puts v.foo }

hr = { k: A.new }
hr.replace({ k: D.new })
[A.new, hr[:k]].each { |v| puts v.foo }

# an element merged in through an ivar reaches the reader's calls too
class Box
  def initialize; @items = [A.new]; end
  def add(list) = @items.concat(list)
  def each_foo = @items.each { |e| puts e.foo }
end
b = Box.new
b.add([D.new])
b.each_foo

# the String the merged-in element's []= changes is the caller's own
class Bang; def []=(k, v); v << "!"; end; end
class Quiet; def []=(k, v); nil; end; end
x = [Quiet.new]
x.concat([Bang.new])
w = x[ARGV.size + 1]
s = { "a" => String.new("v") }
s.each { |k, v| w[k] = v }
puts s["a"]
