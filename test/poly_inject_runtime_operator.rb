# inject on a value that may be one of several kinds of collection, given
# its operator only at run time: a Symbol or a String names it, anything
# else raises TypeError

def w(a, x) = a.inject(x)
p w(%w[a b], "+")
p w([1.5, 2.5], :+)
p w({ a: 1 }, :+)
p((w([1, 2], 5) rescue "#{$!.class}: #{$!.message}"))
p w([1, 2, 3], "*")
