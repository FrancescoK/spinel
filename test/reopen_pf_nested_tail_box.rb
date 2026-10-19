# The tail of a block a String reopening's yielding method hands back can be
# a call of that same kind (`"b".pm(v) { |w| w }`) or a catch, whose answer
# is the String it was handed. Read as the block's box it was a copy of the
# String's text, so a change through the result never reached the original.
class String
  def pm(a) = yield(a)
end

s = +"yy"
r = "a".pm(s) { |v| "b".pm(v) { |w| w } }
r << "1"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| "b".pm(v) { |w| "c".pm(w) { |x| x } } }
r << "2"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| z = 1; "b".pm(v) { |w| w } }
r << "3"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| "b".pm(v) { |w| z = 1; w } }
r << "4"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| v ? "b".pm(v) { |w| w } : "none" }
r << "5"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| ("b".pm(v) { |w| w }) }
r << "6"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| next "b".pm(v) { |w| w } if v.size > 1; "q" }
r << "7"
p s, r.equal?(s)

s = +"yy"
a = "a".pm(s) { |v| ["b".pm(v) { |w| w }] }
a[0] << "8"
p s, a[0].equal?(s)

s = +"yy"
r = "a".pm(s) { |v| catch(:x) { v } }
r << "9"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| catch(:x) { throw :x, v } }
r << "a"
p s, r.equal?(s)

s = +"yy"
r = "a".pm(s) { |v| @kept = "b".pm(v) { |w| w } }
r << "b"
p s, r.equal?(s), @kept.equal?(s)
