# The value of an inlined yield is its block's tail, rendered as the handle
# the tail names: a proc's answer, a `then` or `yield_self` over a callable,
# a `loop`'s break, a `catch`, a bang on a boxed receiver, and a yield whose
# argument is such a `then`. Changing the result shows in the String.
def q = yield
def yb(s) = yield(s.then { |x| x })
s = +"abc"
pr = proc { s }
keep = proc { |x| x }
w = q { pr.call }
w << "1"
p s, w.equal?(s)
w = q { s.then { |x| x } }
w << "2"
p s, w.equal?(s)
w = q { loop { break s } }
w << "3"
p s, w.equal?(s)
w = q { catch(:x) { s } }
w << "4"
p s, w.equal?(s)
w = s.yield_self(&keep)
w << "5"
p s, w.equal?(s)
a = [s, 1]
w = q { a[0].upcase! }
w << "6"
p s, w.equal?(s)
yb(s) { |t| t << "7" }
p s
w = q { +"fresh" }
w << "8"
p s, w
# a tail that is another yielding call, a call answering its own block's
# value, a user method's yield, and a dispatch on a boxed receiver
def q2(x) = yield(x)
class G; def g = yield(1); end
class A1; def initialize(s) = (@s = s); def f = @s; end
class B1; def f = +"bb"; end
w = q { q { s } }
w << "9"
p s, w.equal?(s)
w = q { q2(s) { |t| t } }
w << "a"
p s, w.equal?(s)
o = ARGV.size == 0 ? A1.new(s) : B1.new
w = q { o.f }
w << "b"
p s, w.equal?(s)
