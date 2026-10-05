# In-place gsub!/sub!/tr!/delete!/slice! reassign the transformed value
# (statement position; the nil-when-unchanged return is not modeled, like
# the other bang methods).
s = +"hello"
s.gsub!("l", "L")
puts s
t = +"hello"
t.sub!("l", "_")
puts t
u = +"hello"
u.tr!("el", "ip")
puts u
v = +"hello"
v.delete!("l")
puts v
w = +"hello world"
w.slice!(5, 6)
puts w
x = +"hello"
x.slice!("ll")
puts x
y = +"hello"
y.slice!(2, 99)
puts y
z = +"hello"
z.gsub!(/l+/, "L")
puts z
