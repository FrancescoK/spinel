# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
c = ARGV.size == 0
s = +"abc"
a = [1, "p", :q]
a[1], a[2] = (c ? s : +"q"), s.then { |q| q }
a[1] << "!"
p s, a, a[1].equal?(s), a[2].equal?(s)
