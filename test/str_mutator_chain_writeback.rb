# insert, prepend, concat, replace and << answer their receiver, so a
# mutator straight on their result changes the variable too, as in CRuby;
# the second mutation had landed in a copy.
t = +"ab"
t.insert(1, "-").sub!("-", "+")
p t
t = +"ab"
t.concat("-").sub!("-", "+")
p t
t = +"ab"
t.prepend("-").gsub!("-", "+")
p t
t = +"ab"
t.replace("x-").tr!("-", "+")
p t
t = +"ab"
(t << "-").squeeze!("-")
p t
t = +"ab"
t.insert(0, "x").upcase!
p t
t = +"ab"
t.insert(0, "x") << "y"
p t
t = +"ab"
t.upcase!.insert(0, "x")
p t
t = +"ab"
t << "c" << "d"
p t
u = t.concat("!").reverse
p t, u
