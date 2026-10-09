# The same as a literal's element: the Hash holds u itself. Refused, as
# `v = id(u); h = { k: v }` is.
def id(x) = x
u = +"u"
h = { k: id(u) }
u << "z"
p h[:k]
