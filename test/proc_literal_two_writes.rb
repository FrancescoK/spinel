# A local written nil and then a lambda (or the lambda and then nil), called
# through the local: `x = nil; x = ->(s) { s + "?" }; x.call("m")`. The local
# holds a box (the nil beside the Proc), and the literal's parameters took the
# Integer default of a literal nothing hands on: the String was read through an
# Integer slot and `s + "?"` raised, or the call printed a pointer as an
# integer. A literal that is one of several writes of its local shares the slot
# with the others, and its parameters are boxed.
x = nil
x = ->(s) { s + "?" }
p x.call("m")

y = nil
y = lambda { |s| s * 2 } if ARGV.empty?
p y.call("ab")

z = lambda { |s| s * 2 }
p z.call("ab")
z = nil if ARGV.size > 3
p z.call("cd")

w = nil
w = proc { |a, b| [a, b] }
p w.call(1, 2), w.call("a", "b")
p %w[x y].map(&x)
