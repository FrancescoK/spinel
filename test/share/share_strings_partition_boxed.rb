# A boxed String partition keeps the matching separator.
def boxed_text(i) = [+"a-b", 1][i]
s = boxed_text(0)
sep = +"-"
a = s.partition(sep)
a[0] << "!"
a[1] << "?"
p [s, sep, a]
