# An operator assignment's value on a receiver of several classes, one of
# which has a writer of its own: each class's writer stores the new value,
# and the assignment answers it (the attr writers' classes raised
# NoMethodError).
class P; attr_accessor :a; end
class Q; attr_accessor :a; end
class R; attr_reader :a; def a=(v); @a = v; end; end
objs = [P.new, Q.new, R.new]
objs.each { |r| r.a = "s" }
objs.each { |r| x = (r.a += "y"); p x }
p objs.map(&:a)
objs.each { |r| p(r.a = r.a + "z") }
p objs.map(&:a)
n = [P.new, R.new]
n.each { |r| r.a = 1 }
p n.map { |r| r.a += 2 }, n.map(&:a)
