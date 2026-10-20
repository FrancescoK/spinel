# A local written nil and then a lambda (or the lambda and then nil), called
# through the local: `x = nil; x = ->(s) { s + "?" }; x.call("m")`. The local
# holds a box (the nil beside the Proc), and the literal's parameters took the
# Integer default of a literal nothing hands on: the String was read through an
# Integer slot and `s + "?"` raised, or the call printed a pointer as an
# integer. A literal that is one of several writes of its local shares the slot
# with the others, and its parameters are boxed. A local that only ever holds
# procs keeps its typed parameters; and two literals whose answers differ in
# kind answer their join, where the call read the first literal's answer
# through the second's type.
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

def twice(&b)
  b = proc { |v| v * 2 }
  [b.call(21), block_given?]
end
p twice { 1 }

g = proc { |a, b| [a, b] }
p g.call(1)
g = ->(s) { s.to_s * 2 }
p g.call(4), g.call("z")

f = ->(s) { s + s }
p f.call("ab"), f.call(2)
f = ->(s) { [s, s.class] }
p f.call("q"), f.call(2.5), f.call([1])

h = ->(v) { v.size }
p h.call("abc")
h = ->(v) { v.to_s }
p h.call(12)

k = ->(s) { s.to_s }
p k.call(1)
k = ->(s) { [s] }
p k.call(2)
