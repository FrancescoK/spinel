# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
s = +"abc"
outs = []
60.times do |i|
  px = i % 3 == 0 ? PB.new : PA.new
  outs << (px.pick(s) << ("y" * 40) + i.to_s)
end
p s.size, outs.count { |o| o.equal?(s) }, outs[0].size
