# A bang on an element of an Array a builtin made (each_slice's rows, split's
# Strings), as the tail of a block a method yields to, answers the element's
# own String: a change through the call's value shows in the Array, as in
# CRuby. The handle face did not render such a tail (it was taken to answer a
# new String the Array never sees), so the program was refused.
def q = yield

rows = "ab cd ef gh".split.each_slice(2).to_a
w = q { rows[0][0].upcase! }
w << "!"
p rows, w

# the same in a parenthesized sequence
seq = "ab cd ef gh".split.each_slice(2).to_a
v = q { (1; seq[1][0].upcase!) }
v << "?"
p seq, v

# a bang that changes nothing answers nil
none = "AB cd".split.each_slice(2).to_a
p q { none[0][0].upcase! }
p none

# through `then`
th = "ab cd ef gh".split.each_slice(2).to_a
t = th.then { |r| r[0][1].upcase! }
t << "#"
p th, t
