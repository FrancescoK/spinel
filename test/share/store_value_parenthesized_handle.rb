# A String stored into a container from inside parentheses (`r << (x.inspect)`,
# `a[i] = begin ... end`) is the String the container keeps: a change made
# through the element read back shows in the container, as it does without
# the parentheses.
r = []
r << (nil.inspect)
a = [r[0]]
a[0] << "!"
p a

r = []
r << ((12.inspect))
a = [r[0]]
a[0] << "?"
p a

r = []
r << (k = 1; nil.inspect)
a = [r[0]]
a[0] << "+"
p a, k

h = {}
h[:k] = (nil.inspect)
b = [h[:k]]
b[0] << "!"
p b

s = +"abc"
a = [1, 2, 3]
a[1] = begin; s << "y"; s; end
s << "!"
p a, s

x = +"src"
r = []
[x, 12, nil].each { |v| r << (v.inspect) }
e = r[2]
e << "!" if e.is_a?(String) && !e.frozen?
p r

r = []
[x, 12, nil].each { |v| r << (v.to_s * 2) }
e = r[2]
e << "!" if e.is_a?(String) && !e.frozen?
p r

t = +"ab"
r = []
r << (t)
t << "!"
r[0] << "?"
p r, t

z = []
[+"bp"].each { |q| z << (q) }
z[0] << "!"
p z
