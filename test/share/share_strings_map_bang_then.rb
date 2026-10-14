# Under --share-strings map! keeps its block's value as it is, and
# `s.then { |x| x }` is s itself: the element and s are one String.
s = +"abc"
a = [1, 2]
a.map! { s.then { |x| x } }
a[0] << "!"
p s
