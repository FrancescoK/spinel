# recv.method(:m) on a boxed receiver binds the receiver's builtin method:
# calling it runs that method on the same object (a mutator mutates it).
x = [[1], "s"]
x.each { |o| o.method(:push).call(9) if o.is_a?(Array) }
p x

y = [[1], "s", { a: 1 }, 5]
p y[1].method(:upcase).call
p y[0].method(:size).call
y[0].method(:<<).call(5)
p y[0]
y[0].method(:concat).call([6])
p y[0]
y[2].method(:store).call(:b, 2)
p y[2]
p y[2].method(:keys).call
m = y[0].method(:unshift)
m.call(0)
p y[0]
p y[0].method(:pop).call
p y[0]
p y[3].method(:+).call(1)
p [1, 2].map(&y[3].method(:*))
q = y[0].method(:include?)
p q.call(5), q.call(9)
p y[0].method(:push).arity, y[0].method(:include?).arity, y[1].method(:upcase).arity
p y[0].method(:push).name
