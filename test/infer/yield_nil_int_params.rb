# A block parameter bound an Integer at one site and nil at another stays an
# sp_int, the nil bound as the sentinel: `yield 1; yield nil`, a nil element
# of `yield(*[i, nil])` (unboxed to the sentinel), a `= nil` default, and a
# proc called with nil, whose prologue reads the nil off the side channel.
def two(i) = (yield i; yield nil)
def lit(i) = yield(*[i, nil])
def opt(i) = (yield i; yield i, i + 1)
t = 0
two(3) { |a| t += a if a }
lit(4) { |c, d| t += c; p d }
opt(5) { |e, f = nil| t += f if f }
pr = proc { |g| t += g if g }
pr.call(6)
pr.call(nil)
p t
