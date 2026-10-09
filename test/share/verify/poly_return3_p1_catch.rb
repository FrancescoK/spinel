class A; def foo = +"a" + "b"; end
class B; def foo = 7; end
objs = [A.new, B.new]
r = catch(:t) { throw :t, objs[0].foo }
a = r
b = r
a << "x"
p b
p r
