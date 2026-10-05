# The second push of a chain adds s itself to the Array; the element store
# sees only the first one, so the Array holds a copy of s and misses the
# append: refused.
s = +"a"
t = +"b"
a = []
a << t << s
s << "!"
p a
