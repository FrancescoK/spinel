# A block parameter bound Floats and, at some site, nothing or a literal nil
# stays an sp_float marked nullable, as an Integer one does: `yield(*xs)` of
# a Float array into `|a, b|`, `yield 1.5; yield nil`, a nil element of
# `yield(*[x, nil])` (unboxed to the sentinel), a `= nil` default, and a
# proc called with nil, whose prologue reads the nil as the sentinel.
def pair(xs) = yield(*xs)
def two(x) = (yield x; yield nil)
def lit(x) = yield(*[x, nil])
def opt(x) = (yield x; yield x, x + 1.0)
t = 0.0
pair([1.5, 2.5]) { |a, b| t += a * b }
pair([3.5]) { |e, f| p [f, :s] }
two(3.5) { |c| t += c if c }
lit(4.5) { |d, g| t += d; p g }
opt(5.5) { |h, k = nil| t += k if k }
pr = proc { |m| t += m if m }
pr.call(6.5)
pr.call(nil)
p t
