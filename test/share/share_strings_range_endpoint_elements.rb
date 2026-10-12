# --share-strings: a String Range's endpoint (`r.first`, `r.end`, `r.min`)
# stored as an element of an Array or Hash literal no variable holds, and
# read back out by #max, #min or #max_by, is the String the Range keeps.
# The literal kept its typed String form, a copy of each endpoint's bytes,
# so `[r.first, r.last].max` was refused once an endpoint was changed in
# place, even where the copy is never changed (#6765). The literal now
# holds the endpoints' handles, as one the element readers (`[a, b][0]`)
# hand on already does.
# spinel: gc-stress

n = 5
r = (n.to_s + "a")..(n.to_s + "d")
s = String.new("xa")
q = (s..(n.to_s + "x"))
s << "b"
p [r.first, r.last].max, [q.first, q.last].min

# the answer is the endpoint: a change through it changes the Range
m = [q.first, q.last].max
m << "1"
k = [q.begin, q.end].min
k << "2"
p q, m, k

# a later change to the endpoint shows through the answer
lo = [q.min, q.max].min
s << "3"
p lo

# beside a variable's String, a literal String, and in a Hash literal
t = String.new("b")
u = t
m1 = [q.first, t].max
m2 = [q.first, "zz"].min
m3 = {a: q.begin, b: q.end}.min
m4 = {a: q.begin}.max_by { |key, v| v }
m1 << "4"
m2 << "5"
m3[1] << "6"
m4[1] << "7"
u << "8"
p s, t, m1, m2, m3, m4

# held literals and stores, changed through the container
a = [q.first, q.last]
a[0] << "9"
h = {lo: q.begin, hi: q.end}
h[:lo] << "!"
b = []
b << q.first
b[0] << "?"
p q, a, h, b
