# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
px = ARGV.size == 0 ? PA.new : PB.new
s = +"abc"
y = (px.pick(s) << "!")
y << "?"
p s, y, y.equal?(s)
