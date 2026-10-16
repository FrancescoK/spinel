# Under --share-strings a multiple write into an index of a general Array
# keeps the String a parenthesized append answers, the variable's own
# String (#9258).
s = +"abc"
a = [0, 0]
a[0], a[1] = (s << "x"), s
s << "!"
p a, s
