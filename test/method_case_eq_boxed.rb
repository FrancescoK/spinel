# Method#=== calls the method, as Proc#=== calls the proc: a Method read out
# of a container that holds other values too answered false, and the
# argument `===` passes it did not type its parameter (#6179).
def len(x) = x.size
m = [method(:len), 1][ARGV.size]
p(m === "abc")
r = m === "abcd"
p r
p((m === "") ? :truthy : :falsy)
o = [1, method(:len)][ARGV.size]
p(o === 1, o === 2)
