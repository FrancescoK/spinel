# Flag-only: without the flag (as on master) concat reads its receiver argument after appending.
# concat takes its arguments as they were before any is appended, also on
# a String the rule shares.
t = +"x"; a = t
u = t.concat(t, "y", t)
p u, a
s = +"ab"; b = s
s.concat(s, s)
p s, b
