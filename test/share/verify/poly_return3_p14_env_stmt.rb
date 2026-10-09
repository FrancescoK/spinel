class A; def foo = +"a" + "b"; end
class B; def foo = 7; end
objs = [A.new, B.new]
r = objs[0].foo
k = r
ENV["SPX"] = objs[0].foo
p ENV["SPX"]
x = objs[0].foo
ENV.store("SPY", x)
y = x
y << "!"
p ENV["SPY"], x
