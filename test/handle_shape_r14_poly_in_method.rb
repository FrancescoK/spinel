# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
def bump(px, s) = px.pick(s) << "!"
s = +"abc"
bump(PA.new, s)
bump(PB.new, s)
r = bump(PA.new, s)
p s, r.equal?(s)
