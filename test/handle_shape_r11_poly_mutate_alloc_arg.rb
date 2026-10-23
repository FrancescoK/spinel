# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
s = +"abc"
50.times do |i|
  px = i.even? ? PA.new : PB.new
  px.pick(s) << ("x" * 0) << i.to_s * (i % 3)
end
p s.size, s[0, 10]
