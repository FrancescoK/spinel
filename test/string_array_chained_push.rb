# The second push of a chain adds s itself to the Array, and the append to
# s afterwards shows through the element.
s = +"a"
t = +"b"
a = []
a << t << s
s << "!"
p a
