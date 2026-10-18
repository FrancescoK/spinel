# An element read of a local bound to split's Array, mutated in place while
# the Array is read again: the read is a copy of the element in the default
# build, so the mutation would be lost to the Array. Refused.
a = "x,y".split(",")
a[0].upcase!
p a
