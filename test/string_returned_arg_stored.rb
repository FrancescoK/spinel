# id answers its argument, so the Array's element is u itself and the append
# shows through it. The element held a copy: refused, as `v = id(u); q << v`
# is.
def id(x) = x
u = +"u"
q = []
q << id(u)
u << "z"
p q
