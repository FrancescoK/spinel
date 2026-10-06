# `s << "y"` answers s itself, so the Array's element is s and a later
# append through the element changes s. The element is a copy today:
# refused.
s = +"a"
a = []
a << (s << "y")
a[0] << "!"
p s
