# split with a Regexp and a limit on a String held in a mixed Array (a
# boxed receiver) splits as a String does: at most limit fields, every
# field for a negative limit, captures kept.
s = [+"a1b22c333d", 1][0]
p s.split(/\d+/, 2), s.split(/\d+/, -1), s.split(/\d+/, 0)
p s.split(/(\d)/, 3), s.split(/x/, 2), s.split(//, 3)
r = /,\s*/
t = [+"a, b,c ,d,", 1][0]
p t.split(r, 2), t.split(r, -1), t.split(r)
