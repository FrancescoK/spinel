# String#slice! in value position returns the removed part (or nil).
s = +"hello world"
removed = s.slice!(0, 6)
p removed
p s
t = +"hello"
r2 = t.slice!("ll")
p r2
p t
u = +"abc"
p u.slice!("zz").inspect
p u
v = +"hello"
p v.slice!(2, 99)
p v
