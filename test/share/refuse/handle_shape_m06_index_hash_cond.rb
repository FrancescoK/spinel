# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
c = ARGV.size == 0
s = +"abc"
h = {}
h[:x], h[:y] = (c ? s : +"q"), s.then { |q| q }
h[:x] << "!"
p s, h, h[:y].equal?(s)
