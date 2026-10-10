# Integer#method(:sym) on a literal or a computed Integer binds and calls
# under --int-overflow=promote too, where the receiver may be boxed: binding
# raised NoMethodError naming the synthesized wrapper.
y = 7
m = 5.method(:to_s)
p m.call, m.call(2)
p m.arity, m.name, m.owner
a = y.abs.method(:+)
p a.call(1), a.arity
p (y + 1).method(:to_s).call
p [1, 2].map(&10.method(:+))
p 5.method(:*).to_proc.call(3)
p 5.method(:to_s).unbind.class
p (2**64 + y).method(:to_s).call
z = 2**64
p z.method(:+).call(1)
