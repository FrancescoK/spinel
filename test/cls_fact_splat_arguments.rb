# A splat argument hands a builtin the elements of the Array it spreads:
# push(*a) and unshift(*a) store them, concat(*a), update(*a) and
# merge!(*a) store their elements. A later read of the receiver can
# answer one of them, and a call on it dispatches to that class's method.
class A; def foo = "A"; end
class B; def foo = "B"; end
class C; def foo = "C"; end

a = []
l = [[B.new]]
a.concat(*l)
[A.new, a[0]].each { |v| puts v.foo }

h = {}
hs = [{ k: C.new }]
h.merge!(*hs)
[A.new, h[:k]].each { |v| puts v.foo }

u = {}
u.update(*[{ k: B.new }])
[A.new, u[:k]].each { |v| puts v.foo }

b = []
b.push(*[C.new])
[A.new, b[0]].each { |v| puts v.foo }

c = []
c.unshift(*[B.new])
[A.new, c[0]].each { |v| puts v.foo }

# the splat's Array read from a local, and the receiver walked whole
x = []
y = [C.new]
x.push(*y)
x.each { |v| puts v.foo }
[A.new].each { |v| puts v.foo }
