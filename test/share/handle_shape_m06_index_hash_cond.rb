# Under --share-strings a multiple write into a key of a general Hash keeps
# the String a conditional answers: the value is that String (#9258).
c = ARGV.size == 0
s = +"abc"
h = {}
h[:x], h[:y] = (c ? s : +"q"), s.then { |q| q }
h[:x] << "!"
p s, h, h[:y].equal?(s)
