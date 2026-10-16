# Under --share-strings a multiple write into an index of a general Array
# keeps the String a conditional answers: the element is that String (#9258).
c = ARGV.size == 0
s = +"abc"
t = +"zz"
a = ["p", "q"]
a[0], a[1] = (c ? s : t), s
a[0] << "!"
p s, a, a[0].equal?(s)
