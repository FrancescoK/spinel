# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings, a second in-place change over a boxed
# receiver's call whose arms answer a String reaches the bytes the first one
# answered, not the String: refused.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
c = ARGV.size == 0
s = +"abc"
px = c ? PA.new : PB.new
px.pick(s).concat("2").concat("3")
p s
