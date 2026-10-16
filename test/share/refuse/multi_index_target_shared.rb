# Flag-only: under --share-strings, a multiple write into an index of a
# general Array stores the bytes of its value, so a String shared with
# another name and answered by a call would be stored as a copy: refused.
s = +"abc"
a = [0, 0]
a[0], a[1] = (s << "x"), s
s << "!"
p a, s
