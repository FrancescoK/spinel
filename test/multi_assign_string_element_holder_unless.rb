# A new String a multiple assignment stores in an Array element that is
# changed in place is that element. The local holding the Array is an
# Array or a Hash by its text when each of its writes is one, through
# an `unless`, an `elsif` ladder or an arm of several statements as well as
# an `if`, and the assignment stores its new Strings as the elements.
# spinel: gc-stress
n = ARGV.size

r = unless n > 0 then [+"q"] else [+"z"] end
r[0], r[1] = +"ab", +"cd"
r[0] << "z"
p r

s = if n > 5 then [+"a"] elsif n > 3 then [+"b"] else [+"c"] end
s[0], s[1] = +"ab", +"cd"
s[0] << "z"
p s

t = if n > 0 then [+"a"] else (n += 1; [+"c"]) end
t[0], t[1] = +"ab", +"cd"
t[1] << "y"
p t

h = unless n > 0 then {"a" => +"q"} else {"a" => +"z"} end
k1 = "x#{n}"
k2 = "y#{n}"
h[k1], h[k2] = +"ef", +"gh"
h[k2] << "w"
h[k1] << "v"
p h.values
