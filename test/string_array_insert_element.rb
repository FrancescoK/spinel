# `insert` adds s itself to the Array, so an append through the element
# changes s. The element store does not see `insert` and keeps a copy:
# refused, as are `prepend` and `concat` of a literal.
s = +"a"
a = []
a.insert(0, s)
a[0] << "!"
p s
