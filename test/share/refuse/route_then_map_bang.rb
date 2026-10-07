# Flag-only: under --share-strings, map! keeps its block's value as it is,
# and a `then` there is a copy of s: refused.
s = +"abc"
a = [1, 2]
a.map! { s.then { |x| x } }
a[0] << "!"
p s
