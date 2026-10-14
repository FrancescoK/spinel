# Under --share-strings a map block's `next +s` hands on s itself (s is not
# frozen): the element and s are one String.
s = +"abc"
a = [1].map { next +s }
a[0] << "!"
p s
