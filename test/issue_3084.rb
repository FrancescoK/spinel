s = +"あいうえお"
s.slice!(1)
p s
s2 = +"あいうえお"
s2.slice!(1, 2)
p s2
s3 = +"あいうえお"
s3.slice!(1..2)
p s3
r = +"日本語ABC"
r.slice!(0, 3)
p r
v = +"あいうえお"
removed = v.slice!(1, 2)
p removed
p v
w = +"café"
w.slice!(-1)
p w
