# String#scan with a pattern that arrives boxed (read out of a table, a
# block parameter over mixed values) tells a Regexp from a String at run
# time: a String pattern scans for its bytes and sets $~, where it was read
# as a compiled Regexp (no rows, or a crash). A boxed Regexp with groups
# gives its capture rows; any other value is CRuby's TypeError.
pat = ["l", 1][0]
p "hello".scan(pat)
p $~[0]
r = []
"hello".scan(pat) { |m| r << m }
p r, $~[0]
lit = ["(l)", 1][0]
p "hel(l)o".scan(lit)
[/./, "l"].each do |pt|
  rows = []
  "hello".scan(pt) { |m| rows << m }
  p rows, "hello".scan(pt)
end
p "hello".scan([/(.)(l)/, 1][0])
s = ["hello", 1][0]
p s.scan(pat)
q = []
s.scan(pat) { |m| q << m }
p q
p(("hello".scan([nil, 2][0]) { } rescue $!.message))
p((s.scan([:l, 2][0]) rescue $!.message))
p(("hello".scan([2.5, "x"][0]) rescue $!.message))
