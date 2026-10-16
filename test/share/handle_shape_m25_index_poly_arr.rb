# Under --share-strings a multiple write into an index of a general Array
# keeps the String each value answers, a conditional's included (#9258).
c = ARGV.size == 0
s = +"abc"
a = [1, "p", :q]
a[1], a[2] = (c ? s : +"q"), s.then { |q| q }
a[1] << "!"
p s, a, a[1].equal?(s), a[2].equal?(s)
