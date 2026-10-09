class A; def foo = +"a" + "b"; end
class B; def foo = 7; end
objs = [A.new, B.new]
r = (ENV["SPX"] = objs[0].foo)
arr = [r, r]
arr[0] << "x"
p arr
