# `s += rhs` takes s's String, runs rhs, then appends rhs to what that
# String holds by then. An rhs that appends to s first (`s << "zz"`) was
# read after the concatenation had already taken s's old bytes; one that
# rebinds s leaves the old String in place. A local that shares its String
# with another one (`t = s` with an append through t) takes `+=` as a
# statement now (it was refused): s names the new String, t keeps the old.
s = +"a"
s += (s << "zz"; "c")
p s

s = +"a"
s += (s = +"q"; "c")
p s

a = +"a"
t = a
t << "q"
a += "c"
p a, t

a = +"a"
t = a
t << "q"
a += (t << ("z" * 300); "c")
p a.size, t.size, a[-1]

a = +"a"
t = a
t << "q"
a += (a = +"w"; "c")
p a, t
