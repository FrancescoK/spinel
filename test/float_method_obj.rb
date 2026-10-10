# Float#method(:sym) binds and calls: the Method's self slot is a pointer,
# and a Float receiver cast to one did not compile.
f = 2.5
m = f.method(:to_s)
p m.call
p 2.5.method(:floor).call, 2.75.method(:round).call(1)
p 1.5.method(:+).call(2), 1.5.method(:*).call(2.0)
p m.arity, m.name, m.owner, 2.5.method(:round).arity
p [1.0, 2.0].map(&0.5.method(:+))
p 7.5.method(:divmod).call(2)
p 2.5.method(:to_s).unbind.class
p 9.0.method(:**).to_proc.call(0.5)
ms = [2.5.method(:floor), 2.5.method(:ceil)]
p ms.map(&:call)
p ms[0].call, ms[1].arity
def run(m) = m.call(3)
p run(1.25.method(:*))
x = 0.1 + 0.2
p x.method(:round).call(2)
