class A; def foo = +"a" + "b"; end
class B; def foo = 7; end
objs = [A.new, B.new]
x = objs[0].foo.to_s
y = x
y << "!"
p x
z = [objs[0].foo.to_s, 1][0]
w = z
w << "?"
p z
