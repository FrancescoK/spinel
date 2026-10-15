# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
c = ARGV.size == 0
s = +"abc"
t = +"zz"
a = ["p", "q"]
a[0], a[1] = (c ? s : t), s
a[0] << "!"
p s, a, a[0].equal?(s)
