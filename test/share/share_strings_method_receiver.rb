# A bound builtin keeps the String it captured when its source grows or
# is rebound. A fresh receiver and its arguments survive later allocations.
s = +"he"
m = s.method(:upcase)
s << "llo"
p m.call
s = +"other"
p m.call
p s
p [1].each_with_object(+"") { |i, b| b << "!" }
q = (+"ab").method(:ljust)
p q.call(5, +".")
p q.to_proc.call(4, +"!")
a = +"foo"
b = a.method(:to_s)
a << "d"
p b.call
def grow(value, suffix:) = value << suffix
v = +"call"
fn = method(:grow)
fn.call(v, suffix: +"!")
p v
source = +"box"
mixed = [source, 1][ARGV.size]
mb = mixed.method(:upcase)
mixed << "!"
p mb.call
