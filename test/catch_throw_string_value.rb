# A String handed through throw reads as the String at the catch, also when
# the program shares it (its box then carries a handle, which the catch
# unboxes as a String; it read the handle's own bytes). The catch's answer is
# read straight away: kept in a variable while the String changes, it would
# be a copy, a route refused until Strings are shared (#6765).
s = +"hello"
s << "~"
p [s, catch(:tg) { throw :tg, s }]
p s
n = catch(:num) { throw :num, [1, 2, 3] }
p n.sum
w = catch(:w) { "plain" }
p w
