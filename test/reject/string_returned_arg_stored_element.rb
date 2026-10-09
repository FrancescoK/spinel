# The append goes through the element and u is read: the element would be a
# fresh handle over a copy of u's String. Refused, as `id(u) << "y"` is.
def id(x) = x
u = +"u"
q = []
q << id(u)
q[0] << "y"
p u
