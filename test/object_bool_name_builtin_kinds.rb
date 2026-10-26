# A program's own Object method whose name ends in `?` answers what it
# returns, not a Boolean, on a Rational, Complex, Proc, Exception or Queue
# receiver too: the call is typed by the method, so a String result is no
# Boolean slot's. Each kind is called in a condition and printed.
class Object
  def foo? = "str"
  def num? = 7
  def maybe?(x) = x > 0 ? "pos" : nil
end

r = Rational(1, 2)
puts "ok" if r.foo?
p r.foo?
p r.num?
p r.maybe?(1)
p r.maybe?(-1)

c = Complex(1, 2)
puts "ok" if c.foo?
p c.foo?
p c.num?

pr = proc { 1 }
puts "ok" if pr.foo?
p pr.foo?
p pr.num?

e = RuntimeError.new("x")
puts "ok" if e.foo?
p e.foo?
p e.num?
p e.maybe?(0)

q = Queue.new
puts "ok" if q.foo?
p q.foo?
p q.num?
