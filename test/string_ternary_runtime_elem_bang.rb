# A conditional with a bang on an element of an Array a builtin made
# (each_slice's rows, split's Strings) on an arm answers the element's own
# String when that arm is taken: a change through the value shows in the
# Array, as in CRuby. A write took the conditional for bytes and refused it
# as a value that would hand on a copy.
c = ARGV.size == 0
r = "ab cd ef gh".split.each_slice(2).to_a
w = c ? r[0][0].upcase! : +"q"
w << "#" if w.is_a?(String)
p r, w

# an argument, a `||` and a `case`
def m(x) = x << "?"
r2 = "ab cd ef gh".split.each_slice(2).to_a
m(c ? r2[0][1].upcase! : +"q")
p r2
r3 = "ab cd ef gh".split.each_slice(2).to_a
v = r3[1][0].upcase! || r3[1][1]
v << "$"
p r3, v
r4 = "ab cd ef gh".split.each_slice(2).to_a
z = case ARGV.size when 0 then r4[1][1].upcase! else +"q" end
z << "%"
p r4, z
