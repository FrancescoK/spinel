# Kernel#String of a value that can be a String or something else (`String(v)`)
# answers the String itself, as `v.to_s` does. As the tail of the block a
# String reopening's yielding method hands back, which the method also yields
# nil to, or of a proc, it came out as a copy of the String's text, so a
# change through the result never reached the original. Any other value is
# converted: a nil is the empty String, an object answering to_str gives that.
class String
  def pm(a) = yield(a)
end

s = +"base"
r = "a".pm(s) { |v| String(v) }
r << "5"
p s, r.equal?(s)
r = "a".pm(nil) { |v| v || s }
r << "8"
p s, r.equal?(s)

pr = proc { |v| String(v) }
s = +"proc"
r = pr.call(s)
r << "!"
p s, r.equal?(s)
r = pr.call(nil)
p r, r.frozen?
r = pr.call(7)
r << "x"
p r

s = +"paren"
r = "a".pm(s) { |v| (String(v)) }
r << "1"
p s, r.equal?(s)
"a".pm(nil) { |v| v }

s = +"cond"
r = "a".pm(s) { |v| v ? String(v) : "none" }
r << "2"
p s, r.equal?(s)
p "a".pm(nil) { |v| v ? String(v) : "none" }

s = +"elem"
a = "a".pm(s) { |v| [String(v)] }
a[0] << "3"
p s, a[0].equal?(s)
"a".pm(nil) { |v| [v] }

class Conv
  def to_str = +"conv"
  def to_s = "plain"
end
r = pr.call(Conv.new)
r << "4"
p r

# the other Kernel conversions
p "a".pm(3) { |v| Integer(v) }
p "a".pm("12") { |v| Integer(v) }
p "a".pm(nil) { |v| Array(v) }
p "a".pm([1]) { |v| Array(v) }
s = +"arr"
a = "a".pm(s) { |v| Array(v) }
a[0] << "6"
p s, a[0].equal?(s)
"a".pm(nil) { |v| Array(v) }
