# A String handed through throw reads as the String at the catch, also when
# the program shares it (its box then carries a handle, which the catch
# unboxes as a String; it read the handle's own bytes).
s = +"hello"
t = catch(:tg) { throw :tg, s }
p [s, t]
s << "~"
p s
n = catch(:num) { throw :num, [1, 2, 3] }
p n.sum
w = catch(:w) { "plain" }
p w
