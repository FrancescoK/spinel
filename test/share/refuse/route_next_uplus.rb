# Flag-only: under --share-strings, a `next` hands a map block's value on as
# it is, and `+s` there is a copy of s: refused.
s = +"abc"
a = [1].map { next +s }
a[0] << "!"
p s
